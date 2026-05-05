module HsMx.Metadata (
  SessionMetadata (..),
  loadSessionMetadata,
  loadSessionMetadataFile,
  writeSessionMetadataFile,
  removeSessionMetadataFile,
  encodeSessionMetadataList,
  sessionIsAlive,
) where

import Control.Exception (IOException, catch)
import qualified Data.Aeson as Aeson
import qualified Data.ByteString.Lazy as BL
import Data.List (sortOn)
import Data.Ord (Down (..))
import Data.Text (Text)
import Data.Time.Clock (UTCTime)
import GHC.Generics (Generic)
import HsMx.Session (SessionName)
import System.Directory (doesDirectoryExist, doesFileExist, listDirectory, removeFile)
import System.FilePath (takeExtension, (</>))
import System.Posix.Signals (nullSignal, signalProcess)
import System.Posix.Types (CPid (..))

data SessionMetadata = SessionMetadata
  { sessionMetadataName :: SessionName,
    sessionMetadataTags :: [Text],
    sessionMetadataWorkingDirectory :: Text,
    sessionMetadataAttachedClients :: Int,
    sessionMetadataCreatedAt :: UTCTime,
    sessionMetadataUpdatedAt :: UTCTime,
    sessionMetadataDaemonPid :: Int,
    sessionMetadataSocketPath :: Text
  }
  deriving (Eq, Show, Generic)

instance Aeson.ToJSON SessionMetadata where
  toJSON = Aeson.genericToJSON Aeson.defaultOptions {Aeson.fieldLabelModifier = drop 15}

instance Aeson.FromJSON SessionMetadata where
  parseJSON = Aeson.genericParseJSON Aeson.defaultOptions {Aeson.fieldLabelModifier = drop 15}

loadSessionMetadata :: FilePath -> IO [SessionMetadata]
loadSessionMetadata stateDir = do
  exists <- doesDirectoryExist stateDir
  if not exists
    then pure []
    else do
      names <- listDirectory stateDir
      sessions <- traverse (loadSessionMetadataFile . (stateDir </>)) (filter ((== ".json") . takeExtension) names)
      alive <- filterMExisting sessions
      pure (sortOn (Down . sessionMetadataUpdatedAt) alive)

loadSessionMetadataFile :: FilePath -> IO (Maybe SessionMetadata)
loadSessionMetadataFile metadataFile = do
  exists <- doesFileExist metadataFile
  if not exists
    then pure Nothing
    else do
      payload <- BL.readFile metadataFile
      case Aeson.decode payload of
        Nothing -> pure Nothing
        Just metadata -> do
          alive <- sessionIsAlive metadata
          if alive then pure (Just metadata) else pure Nothing

writeSessionMetadataFile :: FilePath -> SessionMetadata -> IO ()
writeSessionMetadataFile metadataFile = BL.writeFile metadataFile . Aeson.encode

removeSessionMetadataFile :: FilePath -> IO ()
removeSessionMetadataFile metadataFile = removeFile metadataFile `catch` ignoreMissing

sessionIsAlive :: SessionMetadata -> IO Bool
sessionIsAlive metadata =
  (signalProcess nullSignal (CPid (fromIntegral (sessionMetadataDaemonPid metadata))) >> pure True)
    `catch` \(_ :: IOException) -> pure False

encodeSessionMetadataList :: [SessionMetadata] -> BL.ByteString
encodeSessionMetadataList = Aeson.encode

filterMExisting :: [Maybe SessionMetadata] -> IO [SessionMetadata]
filterMExisting = fmap foldPresent . traverse keepAlive
  where
    keepAlive Nothing = pure Nothing
    keepAlive (Just metadata) = do
      alive <- sessionIsAlive metadata
      pure (if alive then Just metadata else Nothing)

foldPresent :: [Maybe a] -> [a]
foldPresent = foldr step []
  where
    step Nothing acc = acc
    step (Just value) acc = value : acc

ignoreMissing :: IOException -> IO ()
ignoreMissing _ = pure ()
