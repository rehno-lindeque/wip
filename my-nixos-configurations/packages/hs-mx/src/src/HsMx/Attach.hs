module HsMx.Attach (
  startSession,
  attachSession,
  killSession,
  printSessionHistory,
) where

import Control.Concurrent (threadDelay)
import qualified Control.Concurrent.Async as Async
import Control.Exception (IOException, bracket, catch)
import Control.Monad (unless, void)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Text as Text
import Data.Word (Word8)
import HsMx.Cli (AttachOptions (..), HistoryOptions (..), KillOptions (..))
import HsMx.Metadata
import HsMx.Paths
import HsMx.Session
import HsMx.Terminal (currentTerminalSize, prepareTerminalForAttach, restoreTerminalAfterDetach, withRawInput)
import Network.Socket
  ( Family (AF_UNIX),
    ShutdownCmd (ShutdownBoth, ShutdownSend),
    SockAddr (SockAddrUnix),
    Socket,
    SocketType (Stream),
    close,
    connect,
    defaultProtocol,
    shutdown,
    socket,
    withSocketsDo,
  )
import qualified Network.Socket.ByteString as NBS
import System.Directory (doesFileExist, getCurrentDirectory, removeFile)
import System.Environment (getExecutablePath)
import System.Exit (die)
import System.IO (BufferMode (NoBuffering), hFlush, hSetBuffering, hWaitForInput, stdin, stdout)
import qualified System.Posix.IO as PosixIO
import System.Posix.Process (createSession, executeFile, forkProcess)
import System.Posix.Signals (sigKILL, signalProcess)
import System.Posix.Types (CPid (..))

startSession :: AttachOptions -> IO SessionMetadata
startSession options = do
  paths <- getHsMxPaths
  ensureHsMxDirectories paths
  cwd <- maybe getCurrentDirectory pure (attachWorkingDirectory options)
  let sessionName = parseSessionName (attachSessionNameArg options)
      sessionPaths = getSessionPaths paths (sessionNameText sessionName)
  ensureSessionDaemon paths sessionPaths sessionName cwd (attachTags options) (attachStartupCommand options)

attachSession :: AttachOptions -> IO ()
attachSession options = withSocketsDo $ do
  metadata <- startSession options
  connectAndProxy metadata

killSession :: KillOptions -> IO ()
killSession options = do
  paths <- getHsMxPaths
  let sessionName = parseSessionName (killSessionNameArg options)
      sessionPaths = getSessionPaths paths (sessionNameText sessionName)
  metadata <- loadSessionMetadataFile (sessionMetadataFile sessionPaths)
  case metadata of
    Nothing -> die "No such session"
    Just details -> do
      signalProcess sigKILL (CPid (fromIntegral (sessionMetadataDaemonPid details)))
      ignoreIO (removeFile (sessionSocketPath sessionPaths))
      ignoreIO (removeFile (sessionMetadataFile sessionPaths))

printSessionHistory :: HistoryOptions -> IO ()
printSessionHistory options = do
  paths <- getHsMxPaths
  let sessionName = parseSessionName (historySessionNameArg options)
      sessionPaths = getSessionPaths paths (sessionNameText sessionName)
  exists <- doesFileExist (sessionHistoryFile sessionPaths)
  if exists
    then BS.readFile (sessionHistoryFile sessionPaths) >>= BS.hPut stdout
    else die "No history for that session"

ensureSessionDaemon :: HsMxPaths -> SessionPaths -> SessionName -> FilePath -> [String] -> Maybe String -> IO SessionMetadata
ensureSessionDaemon paths sessionPaths sessionName cwd tags startupCommand = do
  existing <- loadSessionMetadataFile (sessionMetadataFile sessionPaths)
  case existing of
    Just metadata -> do
      socketExists <- doesFileExist (Text.unpack (sessionMetadataSocketPath metadata))
      if socketExists
        then pure metadata
        else do
          removeStaleSession sessionPaths
          spawnSessionDaemon paths sessionPaths sessionName cwd tags startupCommand
    Nothing -> spawnSessionDaemon paths sessionPaths sessionName cwd tags startupCommand

spawnSessionDaemon :: HsMxPaths -> SessionPaths -> SessionName -> FilePath -> [String] -> Maybe String -> IO SessionMetadata
spawnSessionDaemon _paths sessionPaths sessionName cwd tags startupCommand = do
  executable <- getExecutablePath
  _ <- forkProcess $ do
    void createSession
    redirectToDevNull
    executeFile executable True (daemonArgs sessionName cwd tags startupCommand) Nothing
  waitForSocket (sessionSocketPath sessionPaths)
  metadata <- loadSessionMetadataFile (sessionMetadataFile sessionPaths)
  maybe (die "Session daemon did not write metadata") pure metadata

daemonArgs :: SessionName -> FilePath -> [String] -> Maybe String -> [String]
daemonArgs sessionName cwd tags startupCommand =
  ["daemon", Text.unpack (sessionNameText sessionName), "--cwd", cwd, "--tags", renderTags tags]
    <> maybe [] (\commandText -> ["--command", commandText]) startupCommand

connectAndProxy :: SessionMetadata -> IO ()
connectAndProxy metadata = withSocketsDo $ do
  let socketPath = Text.unpack (sessionMetadataSocketPath metadata)
  bracket (openSocket socketPath) close $ \sessionSocket -> do
    dimensions <- currentTerminalSize
    NBS.sendAll sessionSocket (encodeDimensions dimensions)
    hSetBuffering stdin NoBuffering
    hSetBuffering stdout NoBuffering
    prepareTerminalForAttach
    withRawInput $ do
      reader <- Async.async (socketToStdout sessionSocket)
      writer <- Async.async (stdinToSocket sessionSocket)
      void (Async.waitCatch reader)
      Async.cancel writer
    restoreTerminalAfterDetach

openSocket :: FilePath -> IO Socket
openSocket socketPath = do
  sessionSocket <- socket AF_UNIX Stream defaultProtocol
  connect sessionSocket (SockAddrUnix socketPath)
  pure sessionSocket

stdinToSocket :: Socket -> IO ()
stdinToSocket sessionSocket = do
  nextByte <- BS.hGetSome stdin 1
  if BS.null nextByte
    then ignoreIO (shutdown sessionSocket ShutdownSend)
    else
      if nextByte == BS.singleton rawDetachByte
        then ignoreIO (shutdown sessionSocket ShutdownSend)
        else
          if nextByte == escapeByte
            then do
              escapeSequence <- readEscapeSequence nextByte
              if escapeSequence `elem` detachPatterns
                then ignoreIO (shutdown sessionSocket ShutdownSend)
                else NBS.sendAll sessionSocket escapeSequence >> stdinToSocket sessionSocket
            else NBS.sendAll sessionSocket nextByte >> stdinToSocket sessionSocket

socketToStdout :: Socket -> IO ()
socketToStdout sessionSocket = do
  chunk <- NBS.recv sessionSocket 4096
  unless (BS.null chunk) $ do
    BS.hPut stdout chunk
    hFlush stdout
    socketToStdout sessionSocket

encodeDimensions :: (Int, Int) -> BS.ByteString
encodeDimensions (widthValue, heightValue) = BS8.pack (show widthValue <> " " <> show heightValue <> "\n")

readEscapeSequence :: BS.ByteString -> IO BS.ByteString
readEscapeSequence initialByte = go initialByte
  where
    go acc = do
      hasMore <- hWaitForInput stdin 10
      if not hasMore
        then pure acc
        else do
          chunk <- BS.hGetSome stdin 1
          if BS.null chunk
            then pure acc
            else go (acc <> chunk)

detachPatterns :: [BS.ByteString]
detachPatterns =
  [ BS8.pack "\ESC[92;5u",
    BS8.pack "\ESC[92;5:1u",
    BS8.pack "\ESC[27;5;92~"
  ]

escapeByte :: BS.ByteString
escapeByte = BS.singleton 27

rawDetachByte :: Word8
rawDetachByte = 28

renderTags :: [String] -> String
renderTags = foldr join ""
  where
    join tagText "" = tagText
    join tagText rest = tagText <> "," <> rest

redirectToDevNull :: IO ()
redirectToDevNull = do
  devNull <- PosixIO.openFd "/dev/null" PosixIO.ReadWrite PosixIO.defaultFileFlags
  _ <- PosixIO.dupTo devNull PosixIO.stdInput
  _ <- PosixIO.dupTo devNull PosixIO.stdOutput
  _ <- PosixIO.dupTo devNull PosixIO.stdError
  PosixIO.closeFd devNull

waitForSocket :: FilePath -> IO ()
waitForSocket socketPath = waitForPath socketPath 100

waitForRemoval :: FilePath -> IO ()
waitForRemoval path = waitForMissing path 100

waitForPath :: FilePath -> Int -> IO ()
waitForPath path attempts = do
  exists <- doesFileExist path
  if exists
    then pure ()
    else
      if attempts <= 0
        then die ("Timed out waiting for " <> path)
        else threadDelay 100000 >> waitForPath path (attempts - 1)

waitForMissing :: FilePath -> Int -> IO ()
waitForMissing path attempts = do
  exists <- doesFileExist path
  if not exists
    then pure ()
    else
      if attempts <= 0
        then die ("Timed out waiting for removal of " <> path)
        else threadDelay 100000 >> waitForMissing path (attempts - 1)

removeStaleSession :: SessionPaths -> IO ()
removeStaleSession sessionPaths = do
  ignoreIO (removeFile (sessionMetadataFile sessionPaths))
  ignoreIO (removeFile (sessionSocketPath sessionPaths))
  ignoreIO (removeFile (sessionHistoryFile sessionPaths))

ignoreIO :: IO () -> IO ()
ignoreIO action = catch action ignoreHandler

ignoreHandler :: IOException -> IO ()
ignoreHandler _ = pure ()
