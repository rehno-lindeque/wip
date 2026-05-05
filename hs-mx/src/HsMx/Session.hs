module HsMx.Session (
  SessionName,
  mkSessionName,
  parseSessionName,
  sessionNameText,
  shellEscape,
) where

import Data.Aeson (FromJSON (parseJSON), ToJSON (toJSON))
import qualified Data.Aeson as Aeson
import Data.Text (Text)
import qualified Data.Text as Text

newtype SessionName = SessionName {sessionNameText :: Text}
  deriving (Eq, Ord, Show)

instance ToJSON SessionName where
  toJSON = Aeson.String . sessionNameText

instance FromJSON SessionName where
  parseJSON value = SessionName <$> parseJSON value

mkSessionName :: Text -> SessionName
mkSessionName = SessionName

parseSessionName :: String -> SessionName
parseSessionName = SessionName . Text.pack

shellEscape :: FilePath -> String
shellEscape value = '\'' : foldr step "'" value
  where
    step '\'' acc = "'\\''" <> acc
    step ch acc = ch : acc
