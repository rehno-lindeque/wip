module Sesh.Cli (
  Command (..),
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
  | StartCommand AttachOptions
  | AttachCommand AttachOptions
  | ListCommand ListOptions
  | KillCommand KillOptions
  | HistoryCommand HistoryOptions
  | DaemonCommand DaemonOptions

data AttachOptions = AttachOptions
  { attachSessionNameArg :: String,
    attachWorkingDirectory :: Maybe FilePath,
    attachTags :: [String],
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
    daemonTags :: [String],
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
    ( command "paths" (info pathsParser (progDesc "Print runtime paths"))
        <> command "start" (info startParser (progDesc "Start a named session without attaching"))
        <> command "attach" (info attachParser (progDesc "Attach to or create a named session"))
        <> command "list" (info listParser (progDesc "List known session metadata"))
        <> command "kill" (info killParser (progDesc "Kill a named session"))
        <> command "history" (info historyParser (progDesc "Print the persisted session output log"))
        <> command "daemon" (info daemonParser (progDesc "Internal detached session daemon"))
    )

pathsParser :: Parser Command
pathsParser = PathsCommand <$> switch (long "json" <> help "Output JSON")

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
    <*> option
      (maybeReader (Just . splitTags))
      ( long "tags"
          <> metavar "TAG,TAG"
          <> value []
          <> help "Comma-separated tags to record in metadata"
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
            <*> option (maybeReader (Just . splitTags)) (long "tags" <> metavar "TAG,TAG" <> value [])
            <*> optional (strOption (long "command" <> metavar "SHELL_SNIPPET"))
        )

splitTags :: String -> [String]
splitTags raw = filter (not . null) (go raw)
  where
    go [] = [[]]
    go (',':rest) = [] : go rest
    go (ch:rest) = case go rest of
      [] -> [[ch]]
      current : remaining -> (ch : current) : remaining
