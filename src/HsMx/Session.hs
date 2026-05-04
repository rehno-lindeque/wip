module HsMx.Session (
  SessionName,
  ProjectPath,
  ProjectPlan (..),
  mkSessionName,
  projectSessionName,
  sessionNameText,
  projectPathText,
  buildProjectPlan,
) where

import Data.Aeson (FromJSON (parseJSON), ToJSON (toJSON))
import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as AesonKey
import Data.Char (isAlphaNum)
import Data.Text (Text)
import qualified Data.Text as Text
import HsMx.Cli (OpenProjectOptions (..))
import HsMx.Paths (defaultProjectsRoot)
import System.Directory (doesDirectoryExist)
import System.FilePath ((</>))

newtype SessionName = SessionName {sessionNameText :: Text}
  deriving (Eq, Ord, Show)

newtype ProjectPath = ProjectPath {projectPathText :: Text}
  deriving (Eq, Ord, Show)

data ProjectPlan = ProjectPlan
  { projectSessionNameValue :: SessionName,
    projectPlanPath :: ProjectPath,
    projectPlanExists :: Bool,
    projectPlanKind :: Text
  }
  deriving (Eq, Show)

instance ToJSON SessionName where
  toJSON = Aeson.String . sessionNameText

instance FromJSON SessionName where
  parseJSON value = SessionName <$> parseJSON value

instance ToJSON ProjectPath where
  toJSON = Aeson.String . projectPathText

instance FromJSON ProjectPath where
  parseJSON value = ProjectPath <$> parseJSON value

instance ToJSON ProjectPlan where
  toJSON plan =
    Aeson.object
      [ AesonKey.fromString "session_name" Aeson..= projectSessionNameValue plan,
        AesonKey.fromString "project_path" Aeson..= projectPlanPath plan,
        AesonKey.fromString "exists" Aeson..= projectPlanExists plan,
        AesonKey.fromString "kind" Aeson..= projectPlanKind plan
      ]

mkSessionName :: Text -> SessionName
mkSessionName = SessionName

projectSessionName :: FilePath -> SessionName
projectSessionName relPath =
  SessionName (Text.pack "projects." <> sanitize (Text.pack relPath))

buildProjectPlan :: OpenProjectOptions -> IO ProjectPlan
buildProjectPlan opts = do
  projectsRoot <- maybe defaultProjectsRoot pure (openProjectsRoot opts)
  let normalized = normalizeProjectPath (openProjectPath opts)
      absolutePath = projectsRoot </> normalized
  exists <- doesDirectoryExist absolutePath
  pure
    ProjectPlan
      { projectSessionNameValue = projectSessionName normalized,
        projectPlanPath = ProjectPath (Text.pack absolutePath),
        projectPlanExists = exists,
        projectPlanKind = Text.pack "project"
      }

normalizeProjectPath :: FilePath -> FilePath
normalizeProjectPath = dropWhile (== '.') . dropWhile (== '/')

sanitize :: Text -> Text
sanitize = squashDots . Text.map replaceChar
  where
    replaceChar c
      | isAlphaNum c = c
      | c `elem` ['.', '_', '-'] = c
      | c == '/' = '.'
      | otherwise = '-'

    squashDots =
      Text.intercalate (Text.pack ".")
        . filter (not . Text.null)
        . Text.splitOn (Text.pack ".")
