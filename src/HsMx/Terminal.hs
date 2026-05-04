module HsMx.Terminal (
  defaultTerminalSize,
  currentTerminalSize,
  withRawInput,
) where

import Control.Exception (bracket)
import qualified System.Console.Terminal.Size as Terminal
import System.IO (BufferMode (NoBuffering), hSetBuffering, hSetEcho, stdin)
import System.Posix.IO (stdInput)
import System.Posix.Terminal
  ( TerminalAttributes,
    TerminalMode (EnableEcho, ExtendedFunctions, KeyboardInterrupts, ProcessInput),
    TerminalState (Immediately),
    getTerminalAttributes,
    queryTerminal,
    setTerminalAttributes,
    withoutMode,
  )

defaultTerminalSize :: (Int, Int)
defaultTerminalSize = (80, 24)

currentTerminalSize :: IO (Int, Int)
currentTerminalSize = do
  window <- Terminal.size
  pure $ case window of
    Nothing -> defaultTerminalSize
    Just measured -> (Terminal.width measured, Terminal.height measured)

withRawInput :: IO a -> IO a
withRawInput action = do
  isTerminal <- queryTerminal stdInput
  hSetBuffering stdin NoBuffering
  if not isTerminal
    then action
    else bracket save restore (const action)
  where
    save = do
      attrs <- getTerminalAttributes stdInput
      hSetEcho stdin False
      setTerminalAttributes stdInput (rawAttributes attrs) Immediately
      pure attrs

    restore attrs = do
      setTerminalAttributes stdInput attrs Immediately
      hSetEcho stdin True

    rawAttributes :: TerminalAttributes -> TerminalAttributes
    rawAttributes attrs =
      foldl withoutMode attrs [EnableEcho, ProcessInput, KeyboardInterrupts, ExtendedFunctions]
