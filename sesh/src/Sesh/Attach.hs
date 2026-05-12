module Sesh.Attach (
  startSession,
  attachSession,
  killSession,
  printSessionHistory,
) where

import Control.Concurrent (MVar, newMVar, threadDelay, withMVar)
import qualified Control.Concurrent.Async as Async
import Control.Exception (IOException, bracket, bracket_, catch)
import Control.Monad (unless, void)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Text as Text
import Data.Word (Word8)
import Sesh.Cli (AttachOptions (..), HistoryOptions (..), KillOptions (..))
import Sesh.Ipc (ClientFrame (..), ServerFrame (..), decodeServerFrames, encodeClientFrame)
import Sesh.Metadata
import Sesh.Paths
import Sesh.Session
import Sesh.Terminal (currentTerminalSize, prepareTerminalForAttach, restoreTerminalAfterDetach, withRawInput)
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
  paths <- getSeshPaths
  ensureSeshDirectories paths
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
  paths <- getSeshPaths
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
  paths <- getSeshPaths
  let sessionName = parseSessionName (historySessionNameArg options)
      sessionPaths = getSessionPaths paths (sessionNameText sessionName)
  exists <- doesFileExist (sessionHistoryFile sessionPaths)
  if exists
    then BS.readFile (sessionHistoryFile sessionPaths) >>= BS.hPut stdout
    else die "No history for that session"

ensureSessionDaemon :: SeshPaths -> SessionPaths -> SessionName -> FilePath -> [String] -> Maybe String -> IO SessionMetadata
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

spawnSessionDaemon :: SeshPaths -> SessionPaths -> SessionName -> FilePath -> [String] -> Maybe String -> IO SessionMetadata
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
    sendLock <- newMVar ()
    sendFrame sendLock sessionSocket (ClientInit dimensions)
    hSetBuffering stdin NoBuffering
    hSetBuffering stdout NoBuffering
    bracket_ prepareTerminalForAttach restoreTerminalAfterDetach $ do
      withRawInput $ do
        reader <- Async.async (socketToStdout sessionSocket)
        writer <- Async.async (stdinToSocket sendLock sessionSocket)
        resizer <- Async.async (resizeToSocket sendLock sessionSocket dimensions)
        void (Async.waitCatch reader)
        Async.cancel writer
        Async.cancel resizer

openSocket :: FilePath -> IO Socket
openSocket socketPath = do
  sessionSocket <- socket AF_UNIX Stream defaultProtocol
  connect sessionSocket (SockAddrUnix socketPath)
  pure sessionSocket

stdinToSocket :: MVar () -> Socket -> IO ()
stdinToSocket sendLock sessionSocket = do
  nextByte <- BS.hGetSome stdin 1
  if BS.null nextByte
    then ignoreIO (shutdown sessionSocket ShutdownSend)
    else
      if nextByte == BS.singleton rawDetachByte
        then detach
        else
          if nextByte == escapeByte
            then do
              escapeSequence <- readEscapeSequence nextByte
              if escapeSequence `elem` detachPatterns
                then detach
                else sendInput escapeSequence >> stdinToSocket sendLock sessionSocket
            else sendInput nextByte >> stdinToSocket sendLock sessionSocket
  where
    sendInput bytes = sendFrame sendLock sessionSocket (ClientInput bytes)
    detach = do
      ignoreIO (sendFrame sendLock sessionSocket ClientDetach)
      ignoreIO (shutdown sessionSocket ShutdownSend)

resizeToSocket :: MVar () -> Socket -> (Int, Int) -> IO ()
resizeToSocket sendLock sessionSocket = go
  where
    go previous = do
      threadDelay 250000
      dimensions <- currentTerminalSize
      if dimensions == previous
        then go previous
        else do
          sendFrame sendLock sessionSocket (ClientResize dimensions)
          go dimensions

sendFrame :: MVar () -> Socket -> ClientFrame -> IO ()
sendFrame sendLock sessionSocket frame =
  withMVar sendLock $ \() -> NBS.sendAll sessionSocket (encodeClientFrame frame)

socketToStdout :: Socket -> IO ()
socketToStdout sessionSocket = go BS.empty
  where
    go buffer = do
      let (frames, rest) = decodeServerFrames buffer
      mapM_ writeFrame frames
      chunk <- NBS.recv sessionSocket 4096
      unless (BS.null chunk) (go (rest <> chunk))

    writeFrame (ServerOutput bytes) = do
      BS.hPut stdout bytes
      hFlush stdout

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
