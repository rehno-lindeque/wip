module HsMx.Terminal (
  defaultTerminalSize,
  currentTerminalSize,
  prepareTerminalForAttach,
  restoreTerminalAfterDetach,
  withRawInput,
) where

import Control.Exception (bracket)
import qualified Data.ByteString.Char8 as BS8
import qualified System.Console.Terminal.Size as Terminal
import System.IO (BufferMode (NoBuffering), hSetBuffering, hSetEcho, stdin, stdout)
import System.Posix.IO (stdInput)
import System.Posix.Terminal
  ( ControlCharacter (Quit),
    TerminalAttributes,
    TerminalMode (EnableEcho, ExtendedFunctions, KeyboardInterrupts, ProcessInput),
    TerminalState (Immediately, WhenFlushed),
    getTerminalAttributes,
    queryTerminal,
    setTerminalAttributes,
    withoutCC,
    withoutMode,
  )

prepareTerminalForAttach :: IO ()
prepareTerminalForAttach = BS8.hPutStr stdout clearSequence

restoreTerminalAfterDetach :: IO ()
restoreTerminalAfterDetach = BS8.hPutStr stdout restoreSequence

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
      setTerminalAttributes stdInput attrs WhenFlushed
      hSetEcho stdin True

    rawAttributes :: TerminalAttributes -> TerminalAttributes
    rawAttributes attrs =
      withoutCC
        (foldl withoutMode attrs [EnableEcho, ProcessInput, KeyboardInterrupts, ExtendedFunctions])
        Quit

clearSequence :: BS8.ByteString
clearSequence = BS8.pack "\ESC[2J\ESC[H"

restoreSequence :: BS8.ByteString
restoreSequence =
  BS8.pack
    ( "\ESC[?1000l\ESC[?1002l\ESC[?1003l\ESC[?1006l"
        <> "\ESC[?2004l\ESC[?1004l\ESC[?1049l"
        <> "\ESC[<u"
        <> "\ESC[?25h"
    )
