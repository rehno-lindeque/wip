module HsMx.Metadata (
  SessionMetadata (..),
  loadSessionMetadata,
  encodeSessionMetadataList,
  encodeProjectPlan,
) where

import qualified Data.Aeson as Aeson
import qualified Data.ByteString.Lazy as BL
import Data.List (sortOn)
import Data.Ord (Down (..))
import Data.Text (Text)
import Data.Time.Clock (UTCTime)
import GHC.Generics (Generic)
import HsMx.Session (ProjectPlan, SessionName)
import System.Directory (doesDirectoryExist, listDirectory)
import System.FilePath ((</>), takeExtension)

data SessionMetadata = SessionMetadata
  { sessionMetadataName :: SessionName,
    sessionMetadataKind :: Text,
    sessionMetadataWorkingDirectory :: Text,
    sessionMetadataAttachedClients :: Int,
    sessionMetadataCreatedAt :: UTCTime,
    sessionMetadataUpdatedAt :: UTCTime
  }
  deriving (Eq, Show, Generic)

instance Aeson.ToJSON SessionMetadata where
  toJSON = Aeson.genericToJSON Aeson.defaultOptions {Aeson.fieldLabelModifier = drop 15}

instance Aeson.FromJSON SessionMetadata where
  parseJSON = Aeson.genericParseJSON Aeson.defaultOptions {Aeson.fieldLabelModifier = drop 15}

loadSessionMetadata :: Maybe FilePath -> IO [SessionMetadata]
loadSessionMetadata Nothing = pure []
loadSessionMetadata (Just stateDir) = do
  exists <- doesDirectoryExist stateDir
  if not exists
    then pure []
    else do
      names <- listDirectory stateDir
      sessions <- traverse (decodeMetadataFile stateDir) (filter ((== ".json") . takeExtension) names)
      pure (sortOn (Down . sessionMetadataUpdatedAt) (foldr collect [] sessions))

decodeMetadataFile :: FilePath -> FilePath -> IO (Maybe SessionMetadata)
decodeMetadataFile stateDir entry = do
  payload <- BL.readFile (stateDir </> entry)
  pure (Aeson.decode payload)

collect :: Maybe a -> [a] -> [a]
collect Nothing acc = acc
collect (Just value) acc = value : acc

encodeSessionMetadataList :: [SessionMetadata] -> BL.ByteString
encodeSessionMetadataList = Aeson.encode

encodeProjectPlan :: ProjectPlan -> BL.ByteString
encodeProjectPlan = Aeson.encode
