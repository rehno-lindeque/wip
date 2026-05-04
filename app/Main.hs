module Main (main) where

import qualified Data.ByteString.Lazy.Char8 as BL8
import qualified Data.Text as Text
import Data.Text (Text)
import Data.Time.Format.ISO8601 (iso8601Show)
import HsMx.Cli
import HsMx.Metadata
import HsMx.Paths
import HsMx.Session

main :: IO ()
main = do
  command <- parseCommand
  case command of
    PathsCommand jsonOutput -> do
      paths <- getHsMxPaths
      if jsonOutput
        then BL8.putStrLn (encodePaths paths)
        else mapM_ putStrLn (renderPaths paths)
    SessionNameCommand projectPath ->
      putStrLn (Text.unpack (sessionNameText (projectSessionName projectPath)))
    OpenProjectCommand opts -> do
      plan <- buildProjectPlan opts
      if openJson opts
        then BL8.putStrLn (encodeProjectPlan plan)
        else mapM_ putStrLn (renderProjectPlan plan)
    ListCommand opts -> do
      paths <- getHsMxPaths
      let sessionDir = maybe (Text.unpack (hsMxSessionDir paths)) id (listStateDir opts)
      sessions <- loadSessionMetadata (Just sessionDir)
      if listJson opts
        then BL8.putStrLn (encodeSessionMetadataList sessions)
        else mapM_ putStrLn (renderSessionSummary <$> sessions)

renderPaths :: HsMxPaths -> [String]
renderPaths paths =
  [ "runtime-dir=" ++ showText (hsMxRuntimeDir paths),
    "session-dir=" ++ showText (hsMxSessionDir paths),
    "socket-dir=" ++ showText (hsMxSocketDir paths)
  ]

renderProjectPlan :: ProjectPlan -> [String]
renderProjectPlan plan =
  [ "session-name=" ++ showText (sessionNameText (projectSessionNameValue plan)),
    "project-path=" ++ showText (projectPathText (projectPlanPath plan)),
    "exists=" ++ show (projectPlanExists plan),
    "kind=" ++ showText (projectPlanKind plan)
  ]

renderSessionSummary :: SessionMetadata -> String
renderSessionSummary metadata =
  unwords
    [ showText (sessionNameText (sessionMetadataName metadata)),
      "clients=" ++ show (sessionMetadataAttachedClients metadata),
      "kind=" ++ showText (sessionMetadataKind metadata),
      "cwd=" ++ showText (sessionMetadataWorkingDirectory metadata),
      "updated=" ++ iso8601Show (sessionMetadataUpdatedAt metadata)
    ]

showText :: Text -> String
showText = Text.unpack
