module HsMx.Attach (
  startSession,
  attachSession,
  openProjectSession,
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
import HsMx.Cli (AttachOptions (..), HistoryOptions (..), KillOptions (..), OpenProjectOptions (..))
import HsMx.Metadata
import HsMx.Paths
import HsMx.Session
import HsMx.Terminal (currentTerminalSize, withRawInput)
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
import System.IO (BufferMode (NoBuffering), hFlush, hSetBuffering, stdin, stdout)
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
  ensureSessionDaemon paths sessionPaths sessionName cwd (attachKind options) (attachStartupCommand options)

attachSession :: AttachOptions -> IO ()
attachSession options = withSocketsDo $ do
  metadata <- startSession options
  connectAndProxy metadata

openProjectSession :: OpenProjectOptions -> IO ()
openProjectSession options = do
  plan <- buildProjectPlan options
  let attachOptions =
        AttachOptions
          { attachSessionNameArg = Text.unpack (sessionNameText (projectSessionNameValue plan)),
            attachWorkingDirectory = Just (Text.unpack (projectPathText (projectPlanPath plan))),
            attachKind = "project",
            attachStartupCommand = Nothing
          }
  attachSession attachOptions

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

ensureSessionDaemon :: HsMxPaths -> SessionPaths -> SessionName -> FilePath -> String -> Maybe String -> IO SessionMetadata
ensureSessionDaemon paths sessionPaths sessionName cwd kind startupCommand = do
  existing <- loadSessionMetadataFile (sessionMetadataFile sessionPaths)
  case existing of
    Just metadata -> do
      socketExists <- doesFileExist (Text.unpack (sessionMetadataSocketPath metadata))
      if socketExists
        then pure metadata
        else do
          removeStaleSession sessionPaths
          spawnSessionDaemon paths sessionPaths sessionName cwd kind startupCommand
    Nothing -> spawnSessionDaemon paths sessionPaths sessionName cwd kind startupCommand

spawnSessionDaemon :: HsMxPaths -> SessionPaths -> SessionName -> FilePath -> String -> Maybe String -> IO SessionMetadata
spawnSessionDaemon _paths sessionPaths sessionName cwd kind startupCommand = do
  executable <- getExecutablePath
  _ <- forkProcess $ do
    void createSession
    redirectToDevNull
    executeFile executable True (daemonArgs sessionName cwd kind startupCommand) Nothing
  waitForSocket (sessionSocketPath sessionPaths)
  metadata <- loadSessionMetadataFile (sessionMetadataFile sessionPaths)
  maybe (die "Session daemon did not write metadata") pure metadata

daemonArgs :: SessionName -> FilePath -> String -> Maybe String -> [String]
daemonArgs sessionName cwd kind startupCommand =
  ["daemon", Text.unpack (sessionNameText sessionName), "--cwd", cwd, "--kind", kind]
    <> maybe [] (\commandText -> ["--command", commandText]) startupCommand

connectAndProxy :: SessionMetadata -> IO ()
connectAndProxy metadata = withSocketsDo $ do
  let socketPath = Text.unpack (sessionMetadataSocketPath metadata)
  bracket (openSocket socketPath) close $ \sessionSocket -> do
    dimensions <- currentTerminalSize
    NBS.sendAll sessionSocket (encodeDimensions dimensions)
    hSetBuffering stdin NoBuffering
    hSetBuffering stdout NoBuffering
    withRawInput $ do
      reader <- Async.async (socketToStdout sessionSocket)
      writer <- Async.async (stdinToSocket sessionSocket)
      void (Async.waitCatch reader)
      Async.cancel writer

openSocket :: FilePath -> IO Socket
openSocket socketPath = do
  sessionSocket <- socket AF_UNIX Stream defaultProtocol
  connect sessionSocket (SockAddrUnix socketPath)
  pure sessionSocket

stdinToSocket :: Socket -> IO ()
stdinToSocket sessionSocket = do
  chunk <- BS.hGetSome stdin 4096
  if BS.null chunk
    then ignoreIO (shutdown sessionSocket ShutdownSend)
    else do
      NBS.sendAll sessionSocket chunk
      stdinToSocket sessionSocket

socketToStdout :: Socket -> IO ()
socketToStdout sessionSocket = do
  chunk <- NBS.recv sessionSocket 4096
  unless (BS.null chunk) $ do
    BS.hPut stdout chunk
    hFlush stdout
    socketToStdout sessionSocket

encodeDimensions :: (Int, Int) -> BS.ByteString
encodeDimensions (widthValue, heightValue) = BS8.pack (show widthValue <> " " <> show heightValue <> "\n")

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
