module Main (main) where

import qualified Data.ByteString.Lazy.Char8 as BL8
import Data.List (intersperse)
import qualified Data.Text as Text
import Data.Text (Text)
import Data.Time.Format.ISO8601 (iso8601Show)
import Sesh.Attach
import Sesh.Cli
import Sesh.Daemon
import Sesh.Metadata
import Sesh.Paths
import Sesh.Session

main :: IO ()
main = do
  command <- parseCommand
  case command of
    PathsCommand jsonOutput -> do
      paths <- getSeshPaths
      if jsonOutput
        then BL8.putStrLn (encodePaths paths)
        else mapM_ putStrLn (renderPaths paths)
    StartCommand opts ->
      do
        _ <- startSession opts
        pure ()
    AttachCommand opts ->
      attachSession opts
    ListCommand opts -> do
      paths <- getSeshPaths
      let sessionDir = maybe (Text.unpack (seshSessionDir paths)) id (listStateDir opts)
      sessions <- loadSessionMetadata sessionDir
      if listJson opts
        then BL8.putStrLn (encodeSessionMetadataList sessions)
        else mapM_ putStrLn (renderSessionSummary <$> sessions)
    KillCommand opts ->
      killSession opts
    HistoryCommand opts ->
      printSessionHistory opts
    DaemonCommand opts ->
      runDaemon opts

renderPaths :: SeshPaths -> [String]
renderPaths paths =
  [ "runtime-dir=" ++ showText (seshRuntimeDir paths),
    "session-dir=" ++ showText (seshSessionDir paths),
    "socket-dir=" ++ showText (seshSocketDir paths)
  ]

renderSessionSummary :: SessionMetadata -> String
renderSessionSummary metadata =
  unwords
    [ showText (sessionNameText (sessionMetadataName metadata)),
      "clients=" ++ show (sessionMetadataAttachedClients metadata),
      "tags=" ++ showTags (sessionMetadataTags metadata),
      "cwd=" ++ showText (sessionMetadataWorkingDirectory metadata),
      "pid=" ++ show (sessionMetadataDaemonPid metadata),
      "updated=" ++ iso8601Show (sessionMetadataUpdatedAt metadata)
    ]

showText :: Text -> String
showText = Text.unpack

showTags :: [Text] -> String
showTags = concat . intersperse "," . fmap Text.unpack
