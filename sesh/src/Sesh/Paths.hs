module Sesh.Paths (
  SeshPaths (..),
  SessionPaths (..),
  getSeshPaths,
  ensureSeshDirectories,
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

data SeshPaths = SeshPaths
  { seshRuntimeDir :: Text,
    seshSessionDir :: Text,
    seshSocketDir :: Text
  }
  deriving (Eq, Show)

data SessionPaths = SessionPaths
  { sessionRootName :: FilePath,
    sessionMetadataFile :: FilePath,
    sessionSocketPath :: FilePath,
    sessionHistoryFile :: FilePath
  }
  deriving (Eq, Show)

getSeshPaths :: IO SeshPaths
getSeshPaths = do
  runtimeDir <- resolveRuntimeDir
  let sessionDir = runtimeDir </> "sessions"
      socketDir = runtimeDir </> "sockets"
  pure
    SeshPaths
      { seshRuntimeDir = Text.pack runtimeDir,
        seshSessionDir = Text.pack sessionDir,
        seshSocketDir = Text.pack socketDir
      }

ensureSeshDirectories :: SeshPaths -> IO ()
ensureSeshDirectories paths = do
  createDirectoryIfMissing True (Text.unpack (seshRuntimeDir paths))
  createDirectoryIfMissing True (Text.unpack (seshSessionDir paths))
  createDirectoryIfMissing True (Text.unpack (seshSocketDir paths))

getSessionPaths :: SeshPaths -> Text -> SessionPaths
getSessionPaths paths sessionName =
  let rootName = sessionFileStem sessionName
      sessionDir = Text.unpack (seshSessionDir paths)
      socketDir = Text.unpack (seshSocketDir paths)
   in SessionPaths
        { sessionRootName = rootName,
          sessionMetadataFile = sessionDir </> (rootName <> ".json"),
          sessionSocketPath = socketDir </> (rootName <> ".sock"),
          sessionHistoryFile = sessionDir </> (rootName <> ".log")
        }

resolveRuntimeDir :: IO FilePath
resolveRuntimeDir = do
  explicit <- lookupEnv "SESH_DIR"
  case explicit of
    Just path -> pure path
    Nothing -> do
      xdgRuntimeDir <- lookupEnv "XDG_RUNTIME_DIR"
      case xdgRuntimeDir of
        Just path -> pure (path </> "sesh")
        Nothing -> do
          home <- getHomeDirectory
          pure (home </> ".local" </> "state" </> "sesh")

sessionFileStem :: Text -> FilePath
sessionFileStem = Text.unpack . Text.map replaceChar
  where
    replaceChar c
      | isAlphaNum c = c
      | c `elem` ['.', '_', '-'] = c
      | otherwise = '_'

encodePaths :: SeshPaths -> BL.ByteString
encodePaths = Aeson.encode . toPathsJson

toPathsJson :: SeshPaths -> Aeson.Value
toPathsJson paths =
  Aeson.object
    [ AesonKey.fromString "runtime_dir" Aeson..= seshRuntimeDir paths,
      AesonKey.fromString "session_dir" Aeson..= seshSessionDir paths,
      AesonKey.fromString "socket_dir" Aeson..= seshSocketDir paths
    ]
