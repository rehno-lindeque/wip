module HsMx.Cli (
  Command (..),
  OpenProjectOptions (..),
  AttachOptions (..),
  ListOptions (..),
  KillOptions (..),
  HistoryOptions (..),
  DaemonOptions (..),
  parseCommand,
) where

import Options.Applicative

data Command
  = PathsCommand Bool
  | SessionNameCommand FilePath
  | OpenProjectCommand OpenProjectOptions
  | StartCommand AttachOptions
  | AttachCommand AttachOptions
  | ListCommand ListOptions
  | KillCommand KillOptions
  | HistoryCommand HistoryOptions
  | DaemonCommand DaemonOptions

data OpenProjectOptions = OpenProjectOptions
  { openProjectPath :: FilePath,
    openProjectsRoot :: Maybe FilePath,
    openJson :: Bool
  }

data AttachOptions = AttachOptions
  { attachSessionNameArg :: String,
    attachWorkingDirectory :: Maybe FilePath,
    attachKind :: String,
    attachStartupCommand :: Maybe String
  }

data ListOptions = ListOptions
  { listStateDir :: Maybe FilePath,
    listJson :: Bool
  }

data KillOptions = KillOptions
  { killSessionNameArg :: String
  }

data HistoryOptions = HistoryOptions
  { historySessionNameArg :: String
  }

data DaemonOptions = DaemonOptions
  { daemonSessionNameArg :: String,
    daemonWorkingDirectory :: FilePath,
    daemonKind :: String,
    daemonStartupCommand :: Maybe String
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
        <> command "open-project" (info openProjectParser (progDesc "Attach to or create a project session"))
        <> command "start" (info startParser (progDesc "Start a named session without attaching"))
        <> command "attach" (info attachParser (progDesc "Attach to or create a named session"))
        <> command "list" (info listParser (progDesc "List known session metadata"))
        <> command "kill" (info killParser (progDesc "Kill a named session"))
        <> command "history" (info historyParser (progDesc "Print the persisted session output log"))
        <> command "daemon" (info daemonParser (progDesc "Internal detached session daemon"))
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
            <*> switch (long "json" <> help "Output the resolved session plan as JSON and exit")
        )

attachParser :: Parser Command
attachParser =
  AttachCommand
    <$> attachOptionsParser

startParser :: Parser Command
startParser =
  StartCommand
    <$> attachOptionsParser

attachOptionsParser :: Parser AttachOptions
attachOptionsParser =
  AttachOptions
    <$> strArgument (metavar "SESSION_NAME" <> help "Session name")
    <*> optional
      ( strOption
          ( long "cwd"
              <> metavar "DIR"
              <> help "Initial working directory for a newly created session"
          )
      )
    <*> strOption
      ( long "kind"
          <> metavar "KIND"
          <> value "shell"
          <> help "Session kind to record in metadata"
      )
    <*> optional
      ( strOption
          ( long "command"
              <> metavar "SHELL_SNIPPET"
              <> help "Shell snippet to run before handing control to the login shell"
          )
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

killParser :: Parser Command
killParser =
  KillCommand
    <$> ( KillOptions
            <$> strArgument (metavar "SESSION_NAME" <> help "Session name")
        )

historyParser :: Parser Command
historyParser =
  HistoryCommand
    <$> ( HistoryOptions
            <$> strArgument (metavar "SESSION_NAME" <> help "Session name")
        )

daemonParser :: Parser Command
daemonParser =
  DaemonCommand
    <$> ( DaemonOptions
            <$> strArgument (metavar "SESSION_NAME")
            <*> strOption (long "cwd" <> metavar "DIR")
            <*> strOption (long "kind" <> metavar "KIND" <> value "shell")
            <*> optional (strOption (long "command" <> metavar "SHELL_SNIPPET"))
        )
