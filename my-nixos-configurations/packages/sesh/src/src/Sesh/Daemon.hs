module Sesh.Daemon (runDaemon) where

import Control.Concurrent (MVar, newEmptyMVar, newMVar, putMVar, readMVar, tryPutMVar)
import Control.Concurrent.MVar (modifyMVar_, swapMVar, takeMVar)
import Control.Concurrent.Async (cancel, waitAnyCatch)
import qualified Control.Concurrent.Async as Async
import Control.Exception (IOException, finally, handle)
import Control.Monad (forever, void)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Text as Text
import Data.Time.Clock (getCurrentTime)
import Sesh.Cli (DaemonOptions (..))
import Sesh.Ipc (ClientFrame (..), decodeClientFrames, encodeClientFrame)
import Sesh.Metadata
import Sesh.Paths
import Sesh.Session
import Sesh.Terminal (defaultTerminalSize)
import Network.Socket
  ( Family (AF_UNIX),
    ShutdownCmd (ShutdownBoth),
    SockAddr (SockAddrUnix),
    Socket,
    SocketType (Stream),
    accept,
    bind,
    close,
    defaultProtocol,
    listen,
    shutdown,
    socket,
    withSocketsDo,
  )
import qualified Network.Socket.ByteString as NBS
import System.Directory (removeFile)
import System.Environment (lookupEnv)
import System.Posix.Process (getProcessID)
import System.Posix.Pty
  ( Pty,
    closePty,
    readPty,
    resizePty,
    spawnWithPty,
    writePty,
  )
import System.Posix.Signals
  ( Handler (CatchOnce),
    installHandler,
    keyboardSignal,
    softwareTermination,
  )
import System.Process (terminateProcess)

runDaemon :: DaemonOptions -> IO ()
runDaemon options = withSocketsDo $ do
  paths <- getSeshPaths
  ensureSeshDirectories paths
  let sessionName = parseSessionName (daemonSessionNameArg options)
      sessionPaths = getSessionPaths paths (sessionNameText sessionName)
  removeIfExists (sessionSocketPath sessionPaths)
  removeIfExists (sessionHistoryFile sessionPaths)

  shell <- defaultShell
  let startupDirectory = daemonWorkingDirectory options
      command = shellStartupCommand shell startupDirectory (daemonStartupCommand options)

  (pty, processHandle) <- spawnWithPty Nothing True shell ["-lc", command] defaultTerminalSize
  daemonPid <- fromIntegral <$> getProcessID
  now <- getCurrentTime
  let initialMetadata =
        SessionMetadata
          { sessionMetadataName = sessionName,
            sessionMetadataTags = map Text.pack (daemonTags options),
            sessionMetadataWorkingDirectory = Text.pack startupDirectory,
            sessionMetadataAttachedClients = 0,
            sessionMetadataCreatedAt = now,
            sessionMetadataUpdatedAt = now,
            sessionMetadataDaemonPid = daemonPid,
            sessionMetadataSocketPath = Text.pack (sessionSocketPath sessionPaths)
          }

  metadataVar <- newMVar initialMetadata
  bufferVar <- newMVar BS.empty
  clientVar <- newMVar Nothing
  stopVar <- newEmptyMVar

  writeSessionMetadataFile (sessionMetadataFile sessionPaths) initialMetadata
  listenSocket <- openSessionSocket (sessionSocketPath sessionPaths)

  void $ installHandler softwareTermination (CatchOnce (void (tryPutMVar stopVar ()))) Nothing
  void $ installHandler keyboardSignal (CatchOnce (void (tryPutMVar stopVar ()))) Nothing

  readerAsync <- Async.async (ptyReaderLoop pty bufferVar clientVar (sessionHistoryFile sessionPaths))
  acceptAsync <- Async.async (acceptLoop listenSocket pty bufferVar clientVar metadataVar (sessionMetadataFile sessionPaths))
  stopAsync <- Async.async (takeStop stopVar)

  void $ waitAnyCatch [readerAsync, acceptAsync, stopAsync]
  cancel readerAsync
  cancel acceptAsync
  cancel stopAsync
  terminateProcess processHandle
  cleanupSession listenSocket pty clientVar (sessionMetadataFile sessionPaths) (sessionSocketPath sessionPaths)

takeStop :: MVar () -> IO ()
takeStop stopVar = do
  _ <- takeMVar stopVar
  pure ()

acceptLoop :: Socket -> Pty -> MVar BS.ByteString -> MVar (Maybe Socket) -> MVar SessionMetadata -> FilePath -> IO ()
acceptLoop listenSocket pty bufferVar clientVar metadataVar metadataFile =
  forever $ do
    (client, _) <- accept listenSocket
    currentClient <- readMVar clientVar
    case currentClient of
      Just _existing -> do
        ignoreIO (NBS.sendAll client (BS8.pack "session already attached\n"))
        close client
      Nothing -> do
        (dimensions, initialFrames) <- receiveHandshake client
        resizePty pty dimensions
        backlog <- readMVar bufferVar
        updateAttachedClients metadataVar metadataFile 1
        setClient clientVar (Just client)
        ignoreIO (NBS.sendAll client backlog)
        let cleanupClient = do
              setClient clientVar Nothing
              ignoreIO (shutdown client ShutdownBoth)
              ignoreIO (close client)
              updateAttachedClients metadataVar metadataFile 0
        proxyClientInput pty client initialFrames `finally` cleanupClient

ptyReaderLoop :: Pty -> MVar BS.ByteString -> MVar (Maybe Socket) -> FilePath -> IO ()
ptyReaderLoop pty bufferVar clientVar historyFile =
  forever $ do
    chunk <- readPty pty
    appendChunk bufferVar chunk
    BS.appendFile historyFile chunk
    maybeClient <- readMVar clientVar
    case maybeClient of
      Nothing -> pure ()
      Just client ->
        ignoreIO (NBS.sendAll client chunk)

proxyClientInput :: Pty -> Socket -> BS.ByteString -> IO ()
proxyClientInput pty client initialBuffer = go initialBuffer
  where
    go buffer = do
      let (frames, rest) = decodeClientFrames buffer
      continue <- handleFrames frames
      if not continue
        then pure ()
        else do
          chunk <- NBS.recv client 4096
          if BS.null chunk
            then pure ()
            else go (rest <> chunk)

    handleFrames [] = pure True
    handleFrames (frame : frames) = do
      continue <- handleFrame frame
      if continue then handleFrames frames else pure False

    handleFrame frame = case frame of
      ClientInit dimensions -> resizePty pty dimensions >> pure True
      ClientInput bytes -> writePty pty bytes >> pure True
      ClientResize dimensions -> resizePty pty dimensions >> pure True
      ClientDetach -> pure False

receiveHandshake :: Socket -> IO ((Int, Int), BS.ByteString)
receiveHandshake client = go BS.empty
  where
    go buffer = do
      let (frames, rest) = decodeClientFrames buffer
      case break isInit frames of
        (_, ClientInit dimensions : trailingFrames) ->
          pure (dimensions, BS.concat (map encodeClientFrame trailingFrames) <> rest)
        _ -> do
          chunk <- NBS.recv client 4096
          if BS.null chunk
            then pure (defaultTerminalSize, BS.empty)
            else go (rest <> chunk)

    isInit (ClientInit _) = True
    isInit _ = False

appendChunk :: MVar BS.ByteString -> BS.ByteString -> IO ()
appendChunk bufferVar chunk =
  modifyMVar_ bufferVar $ \current -> do
    let limit = 262144
        combined = current <> chunk
        trimmed = if BS.length combined > limit then BS.drop (BS.length combined - limit) combined else combined
    pure trimmed

setClient :: MVar (Maybe Socket) -> Maybe Socket -> IO ()
setClient clientVar client = void (swapMVar clientVar client)

updateAttachedClients :: MVar SessionMetadata -> FilePath -> Int -> IO ()
updateAttachedClients metadataVar metadataFile attachedClients = do
  now <- getCurrentTime
  modifyMVar_ metadataVar $ \metadata -> do
    let updated = metadata {sessionMetadataAttachedClients = attachedClients, sessionMetadataUpdatedAt = now}
    writeSessionMetadataFile metadataFile updated
    pure updated

cleanupSession :: Socket -> Pty -> MVar (Maybe Socket) -> FilePath -> FilePath -> IO ()
cleanupSession listenSocket pty clientVar metadataFile socketPath = do
  maybeClient <- readMVar clientVar
  maybe (pure ()) (ignoreIO . close) maybeClient
  ignoreIO (close listenSocket)
  ignoreIO (closePty pty)
  removeSessionMetadataFile metadataFile
  removeIfExists socketPath

openSessionSocket :: FilePath -> IO Socket
openSessionSocket socketPath = do
  sock <- socket AF_UNIX Stream defaultProtocol
  bind sock (SockAddrUnix socketPath)
  listen sock 1
  pure sock

shellStartupCommand :: FilePath -> FilePath -> Maybe String -> String
shellStartupCommand shell cwd startupCommand =
  "cd "
    <> shellEscape cwd
    <> " && "
    <> maybe "" (<> " ; ") startupCommand
    <> "exec "
    <> shellEscape shell
    <> " -l"

defaultShell :: IO FilePath
defaultShell = do
  shell <- lookupEnv "SHELL"
  pure (maybe "/bin/sh" id shell)

removeIfExists :: FilePath -> IO ()
removeIfExists path = ignoreIO (removeFile path)

ignoreIO :: IO () -> IO ()
ignoreIO action = handle ignoreHandler action

ignoreHandler :: IOException -> IO ()
ignoreHandler _ = pure ()
