module HsMx.Paths (
  HsMxPaths (..),
  SessionPaths (..),
  getHsMxPaths,
  ensureHsMxDirectories,
  getSessionPaths,
  encodePaths,
) where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as AesonKey
import qualified Data.ByteString.Lazy as BL
import Data.Char (isAlphaNum)
import Data.Text (Text)
import qualified Data.Text as Text
import System.Directory (createDirectoryIfMissing, getHomeDirectory)
import System.Environment (lookupEnv)
import System.FilePath ((</>))

data HsMxPaths = HsMxPaths
  { hsMxRuntimeDir :: Text,
    hsMxSessionDir :: Text,
    hsMxSocketDir :: Text
  }
  deriving (Eq, Show)

data SessionPaths = SessionPaths
  { sessionRootName :: FilePath,
    sessionMetadataFile :: FilePath,
    sessionSocketPath :: FilePath,
    sessionHistoryFile :: FilePath
  }
  deriving (Eq, Show)

getHsMxPaths :: IO HsMxPaths
getHsMxPaths = do
  runtimeDir <- resolveRuntimeDir
  let sessionDir = runtimeDir </> "sessions"
      socketDir = runtimeDir </> "sockets"
  pure
    HsMxPaths
      { hsMxRuntimeDir = Text.pack runtimeDir,
        hsMxSessionDir = Text.pack sessionDir,
        hsMxSocketDir = Text.pack socketDir
      }

ensureHsMxDirectories :: HsMxPaths -> IO ()
ensureHsMxDirectories paths = do
  createDirectoryIfMissing True (Text.unpack (hsMxRuntimeDir paths))
  createDirectoryIfMissing True (Text.unpack (hsMxSessionDir paths))
  createDirectoryIfMissing True (Text.unpack (hsMxSocketDir paths))

getSessionPaths :: HsMxPaths -> Text -> SessionPaths
getSessionPaths paths sessionName =
  let rootName = sessionFileStem sessionName
      sessionDir = Text.unpack (hsMxSessionDir paths)
      socketDir = Text.unpack (hsMxSocketDir paths)
   in SessionPaths
        { sessionRootName = rootName,
          sessionMetadataFile = sessionDir </> (rootName <> ".json"),
          sessionSocketPath = socketDir </> (rootName <> ".sock"),
          sessionHistoryFile = sessionDir </> (rootName <> ".log")
        }

resolveRuntimeDir :: IO FilePath
resolveRuntimeDir = do
  explicit <- lookupEnv "HS_MX_DIR"
  case explicit of
    Just path -> pure path
    Nothing -> do
      xdgRuntimeDir <- lookupEnv "XDG_RUNTIME_DIR"
      case xdgRuntimeDir of
        Just path -> pure (path </> "hs-mx")
        Nothing -> do
          home <- getHomeDirectory
          pure (home </> ".local" </> "state" </> "hs-mx")

sessionFileStem :: Text -> FilePath
sessionFileStem = Text.unpack . Text.map replaceChar
  where
    replaceChar c
      | isAlphaNum c = c
      | c `elem` ['.', '_', '-'] = c
      | otherwise = '_'

encodePaths :: HsMxPaths -> BL.ByteString
encodePaths = Aeson.encode . toPathsJson

toPathsJson :: HsMxPaths -> Aeson.Value
toPathsJson paths =
  Aeson.object
    [ AesonKey.fromString "runtime_dir" Aeson..= hsMxRuntimeDir paths,
      AesonKey.fromString "session_dir" Aeson..= hsMxSessionDir paths,
      AesonKey.fromString "socket_dir" Aeson..= hsMxSocketDir paths
    ]
