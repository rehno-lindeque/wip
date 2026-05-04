module HsMx.Cli (
  Command (..),
  OpenProjectOptions (..),
  ListOptions (..),
  parseCommand,
) where

import Options.Applicative

data Command
  = PathsCommand Bool
  | SessionNameCommand FilePath
  | OpenProjectCommand OpenProjectOptions
  | ListCommand ListOptions

data OpenProjectOptions = OpenProjectOptions
  { openProjectPath :: FilePath,
    openProjectsRoot :: Maybe FilePath,
    openJson :: Bool
  }

data ListOptions = ListOptions
  { listStateDir :: Maybe FilePath,
    listJson :: Bool
  }

parseCommand :: IO Command
parseCommand = execParser parserInfo

parserInfo :: ParserInfo Command
parserInfo =
  info
    (helper <*> commandParser)
    (fullDesc <> progDesc "Remote-first persistent session manager")

commandParser :: Parser Command
commandParser =
  hsubparser
    ( command "paths" (info pathsParser (progDesc "Print hs-mx runtime paths"))
        <> command "session-name" (info sessionNameParser (progDesc "Derive a stable session name"))
        <> command "open-project" (info openProjectParser (progDesc "Plan a project-backed session"))
        <> command "list" (info listParser (progDesc "List known session metadata"))
    )

pathsParser :: Parser Command
pathsParser = PathsCommand <$> switch (long "json" <> help "Output JSON")

sessionNameParser :: Parser Command
sessionNameParser =
  SessionNameCommand
    <$> strArgument (metavar "PROJECT_PATH" <> help "Relative project path")

openProjectParser :: Parser Command
openProjectParser =
  OpenProjectCommand
    <$> ( OpenProjectOptions
            <$> strArgument (metavar "PROJECT_PATH" <> help "Relative project path under the projects root")
            <*> optional
              ( strOption
                  ( long "projects-root"
                      <> metavar "DIR"
                      <> help "Override the default projects root"
                  )
              )
            <*> switch (long "json" <> help "Output JSON")
        )

listParser :: Parser Command
listParser =
  ListCommand
    <$> ( ListOptions
            <$> optional
              ( strOption
                  ( long "state-dir"
                      <> metavar "DIR"
                      <> help "Read session metadata from this directory"
                  )
              )
            <*> switch (long "json" <> help "Output JSON")
        )
