module HsMx.Paths (
  HsMxPaths (..),
  getHsMxPaths,
  defaultProjectsRoot,
  encodePaths,
) where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as AesonKey
import qualified Data.ByteString.Lazy as BL
import Data.Text (Text)
import qualified Data.Text as Text
import System.Directory (getHomeDirectory)
import System.Environment (lookupEnv)
import System.FilePath ((</>))

data HsMxPaths = HsMxPaths
  { hsMxRuntimeDir :: Text,
    hsMxSessionDir :: Text,
    hsMxSocketDir :: Text
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

defaultProjectsRoot :: IO FilePath
defaultProjectsRoot = do
  home <- getHomeDirectory
  pure (home </> "projects")

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

encodePaths :: HsMxPaths -> BL.ByteString
encodePaths = Aeson.encode . toPathsJson

toPathsJson :: HsMxPaths -> Aeson.Value
toPathsJson paths =
  Aeson.object
    [ AesonKey.fromString "runtime_dir" Aeson..= hsMxRuntimeDir paths,
      AesonKey.fromString "session_dir" Aeson..= hsMxSessionDir paths,
      AesonKey.fromString "socket_dir" Aeson..= hsMxSocketDir paths
    ]
