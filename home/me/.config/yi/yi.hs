{-# LANGUAGE OverloadedStrings #-}

-- import           Control.Monad.Trans
-- import           Control.Applicative ((<|>), (*>), Applicative)
-- import           Control.Lens ((%~), (&))
-- import           Control.Monad
import           Data.Monoid          ((<>))
-- import           Data.Bits
import           Yi
-- import           Yi.Search (resetRegexE)
import           Yi.Fuzzy
import           Yi.Hoogle
import           Yi.Style.Monokai
import           Yi.UI.Pango          (start)
-- import qualified Yi.Keymap.Emacs as Emacs
-- import qualified Yi.Mode.Haskell as Haskell
-- import           Yi.Mode.Haskell.Utils (ghciInsertMissingTypes,
--                                         getTypeAtPoint, caseSplitAtPoint)
-- import           Yi.Mode.Haskell.Utils.PastePipe (lpasteCustom)
-- import           Yi.Monad (gets)

-- import qualified Yi.Keymap.Cua           as C

import qualified Yi.Keymap.Vim        as V
import qualified Yi.Keymap.Vim.Common as V
import qualified Yi.Keymap.Vim.Utils  as V
-- import qualified Yi.Keymap.Vim.Search as V
-- import qualified Yi.Keymap.Vim.NormalMap as V

import qualified Data.Text            as T

{- Fuuzetsu config -}

-- before ∷ Applicative f ⇒ f a → f b → f a
-- before f g = g *> f
--
-- after ∷ Applicative f ⇒ f a → f b → f b
-- after f g = f *> g
--
-- around ∷ Applicative f ⇒ f a → f b → f b
-- around f g = g *> f *> g
--
-- myModeTable :: [AnyMode]
-- myModeTable =
--   [ AnyMode $ haskellModeHooks Haskell.preciseMode
--   ] ++ modeTable defaultEmacsConfig
--
--
-- myKeymap ∷ KeymapSet
-- myKeymap = Emacs.mkKeymap $ override Emacs.defKeymap $ \proto _ ->
--    proto & Emacs.eKeymap %~
--    (||> choice
--       [ ctrlCh 'x' ?>> ctrlCh 's' ?>>! saveAndTruncate
--       , ctrlCh 'c' ?>> ctrlCh 'f' ?>>! fuzzyOpen
--       , metaCh 'p' ?>>! prevNParagraphs 1
--       , metaCh 'n' ?>>! nextNParagraphs 1
--       ])
--
-- saveAndTruncate ∷ YiM ()
-- saveAndTruncate = before fwriteE $ withBuffer deleteTrailingSpaceB
--
-- haskellModeHooks :: Mode syntax -> Mode syntax
-- haskellModeHooks mode =
--   mode { modeKeymap =
--             topKeymapA %~ ((ctrlCh 'c' ?>> choice cMaps) <||)
--        }
--   where
--     cMaps = [ ctrlCh 'l' ?>>! ghciLoadBuffer
--             , ctrlCh 'h' ?>> ctrlCh 't' ?>>! Haskell.ghciInferType
--             , ctrlCh 'h' ?>> ctrlCh 'm' ?>>! ghciInsertMissingTypes
--             , ctrlCh 'h' ?>> ctrlCh 'c' ?>>! getTypeAtPoint
--             , ctrlCh 'h' ?>> ctrlCh 's' ?>>! caseSplitAtPoint
--             , ctrlCh 'h' ?>> ctrlCh 'h' ?>>! hoogleSearch
--             , ctrlCh 'h' ?>> ctrlCh 'p' ?>>! withBuffer (gets file) >>= \t ->
--                 lpasteCustom "Fūzetsu" t "haskell"
--             ]
--
-- myConfig :: Config
-- myConfig = defaultEmacsConfig
--   { defaultKm = myKeymap
--   , modeTable = myModeTable
--   }
--
-- main :: IO ()
-- main = yi $ myConfig {
--   defaultKm = defaultKm myConfig
--
--   }

main :: IO ()
main = yi $ myConfig

myConfig = defaultVimConfig
    { modeTable = fmap (onMode myIndent) (modeTable defaultVimConfig)
    -- , defaultKm = defaultKm defaultVimConfig
    , defaultKm = myKeymapSet $ myBindings
    , configUI = (configUI defaultVimConfig)  -- ? Fuuzetsu uses defaultConfig
      { configWindowFill = '~'     -- ?
      , configTheme = monokaiTheme
      }
    , startFrontEnd = start
    }

-- relayoutFromTo :: String -> String -> (Char -> Char)
-- relayoutFromTo keysFrom keysTo = \c ->
--     maybe c fst (find ((== c) . snd)
--                       (zip (keysTo ++ fmap toUpper' keysTo)
--                            (keysFrom ++ fmap toUpper' keysFrom)))
--     -- where toUpper' ';' = ':'
--     --       toUpper' a = toUpper a

myIndent :: Mode s -> Mode s
myIndent m = m {
    modeIndentSettings = IndentSettings
        {
            expandTabs = True,
            shiftWidth = 4,
            tabSize    = 4
        }}

-- myKeymap ∷ KeymapSet
-- myKeymap = Emacs.mkKeymap $ override Emacs.defKeymap $ \proto _ ->
--    proto & Emacs.eKeymap %~
--    (||> choice
--       [ ctrlCh 'x' ?>> ctrlCh 's' ?>>! saveAndTruncate
--       , ctrlCh 'c' ?>> ctrlCh 'f' ?>>! fuzzyOpen
--       , metaCh 'p' ?>>! prevNParagraphs 1
--       , metaCh 'n' ?>>! nextNParagraphs 1
--       ])

myKeymapSet :: ((V.EventString -> EditorM ()) -> [V.VimBinding]) -> KeymapSet
myKeymapSet bindings = V.mkKeymapSet $ V.defVimConfig `override` \super this ->
    let eval = V.pureEval this
    in super {
            -- From Michal.hs config file
            -- See Yi.Keymap.Vim.Common and Yi.Keymap.Vim.Utils
            V.vimBindings = bindings eval <> V.vimBindings super
        }

myBindings :: (V.EventString -> EditorM ()) -> [V.VimBinding]
myBindings eval =
    let -- YiM actions
        nmapY  eventString action = V.mkStringBindingY V.Normal (eventString, action, id)
        -- EditorM actions
        nmapE  eventString action = V.mkStringBindingE V.Normal V.Drop (eventString, action, id)
        nsmapE eventString action = V.mkStringBindingE (V.Search V.Normal Forward) V.Drop (eventString, action, id)
        imapE  eventString action = V.VimBindingE (\evs state ->
            case V.vsMode state of
                V.Insert _ -> fmap (const (action >> return V.Continue))
                                   (evs `V.matchesString` eventString)
                _          -> V.NoMatch)
    in [
         -- File management
         nmapY "<C-p>" fuzzyOpen

         -- Motion
       , imapE "<Home>" (withCurrentBuffer moveToSol)
       , imapE "<End>"  (withCurrentBuffer moveToEol)

         -- nsmap "ff"     (eval "/")
         -- nsmap "ff"     searchBinding
         -- nmap "ff"     -- V.continueSearching id
         -- nmap "ff"     V.addVimJumpHereE >> V.withCount  (continueSearch id), resetCount -- (continueSearching id), resetCount
--       nmap " "      resetRegexE
--     , nmap ";"      (eval ":")
--     , nmap "<C-l>"  (eval ":ls<CR>")
--
--     , imap "<PageUp>" (...)
--     , imap "<PageDown>" (...)
       ]
  -- where
  --   searchBinding :: V.VimBinding
  --   searchBinding = V.VimBindingE (f . T.unpack . _unEv)
  --     where f evs (V.VimState { V.vsMode = V.Normal }) | evs `elem` T.group ['/', '?']
  --             = V.WholeMatch $ do
  --                   state <- fmap V.vsMode getEditorDyn
  --                   let dir = if evs == "/" then Forward else Backward
  --                   switchModeE $ Search state dir
  --                   isearchInitE dir
  --                   historyStart
  --                   historyPrefixSet T.empty
  --                   return V.Continue
  --           f _ _ = V.NoMatch
-- {-# LANGUAGE TypeFamilies #-}
--
-- import Yi
-- -- Preamble
-- import Yi.Prelude
--
-- -- Import the desired keymap "template":
-- import Yi.Keymap.Emacs (keymap)
-- import Yi.Keymap.Cua (keymap)
--
-- -- Import the desired UI as needed.
-- -- Some are not complied in, so we import none here.
--
-- -- import Yi.UI.Vty (start)
-- -- import Yi.UI.Cocoa (start)
-- -- import Yi.UI.Pango (start)
--
-- import Data.List (isPrefixOf, reverse, drop, length)
-- import Data.Monoid
-- import Yi.Hoogle
-- import Yi.Keymap.Keys
-- import Yi.String
-- import Maybe
-- import qualified Yi.Interact as I
--
-- import Yi.Modes (removeAnnots)
-- import qualified Yi.Mode.Haskell as Haskell
-- import qualified Yi.Syntax.Haskell as Haskell
-- import qualified Yi.Lexer.Haskell as Haskell
-- import qualified Yi.Syntax.Strokes.Haskell as Haskell
-- import Prelude (map)
-- import System.Environment
-- import Yi.Char.Unicode (greek, symbols)
-- import Control.Monad (replicateM_)
-- import Yi.Lexer.Alex (Tok)
-- import qualified Yi.Syntax.Tree as Tree
-- import Yi.Hoogle
-- import Yi.Buffer
-- import Yi.Keymap.Vim (viWrite, v_ex_cmds, v_top_level, v_ins_char, v_opts, tildeop, savingInsertStringB, savingDeleteCharB, exCmds, exHistInfixComplete')
-- import Yi.MiniBuffer (matchingBufferNames)
-- import qualified Yi.Keymap.Vim as Vim
--
-- myModetable :: [AnyMode]
-- myModetable = [
--                AnyMode $ haskellModeHooks Haskell.cleverMode
--               ,
--                AnyMode $ haskellModeHooks Haskell.preciseMode
--               ,
--                AnyMode $ haskellModeHooks Haskell.fastMode
--               ,
--                AnyMode . haskellModeHooks . removeAnnots $ Haskell.cleverMode
--               ,
--                AnyMode $ haskellModeHooks Haskell.fastMode
--               ,
--                AnyMode . haskellModeHooks . removeAnnots $ Haskell.fastMode
--               ]
--
--
-- haskellModeHooks :: (Foldable f) => Endom (Mode (f Haskell.TT))
-- haskellModeHooks mode =
--   -- uncomment for shim:
--   -- Shim.minorMode $
--      mode {
--         modeGetAnnotations = Tree.tokenBasedAnnots Haskell.tokenToAnnot,
--
--         -- modeAdjustBlock = \_ _ -> return (),
--         -- modeGetStrokes = \_ _ _ _ -> [],
--         modeName = "my " ++ modeName mode,
--         -- example of Mode-local rebinding
--         modeKeymap = topKeymapA ^:
--             ((char '\\' ?>> choice [char 'l' ?>>! Haskell.ghciLoadBuffer,
--                                     char 'z' ?>>! Haskell.ghciGet,
--                                     char 'h' ?>>! hoogle,
--                                     char 'r' ?>>! Haskell.ghciSend ":r0",
--                                     char 't' ?>>! Haskell.ghciInferType
--                                    ])
--                       <||)
--      }
--
-- myConfig :: Config -> Config
-- myConfig cfg = cfg
--   { modeTable = fmap (onMode prefIndent) (myModetable ++ modeTable cfg)
--   , defaultKm = Vim.mkKeymap extendedVimKeymap
--   , startActions = startActions cfg ++ [makeAction (maxStatusHeightA %= 10 :: EditorM())]
--   }
--
-- defaultUIConfig = configUI myOldConfig
--
-- -- Change the below to your needs, following the explanation in comments. See
-- -- module Yi.Config for more information on configuration. Other configuration
-- -- examples can be found in the examples directory. You can also use or copy
-- -- another user configuration, which can be found in modules Yi.Users.*
--
-- main :: IO ()
-- main = yi $ myConfig defaultVimConfig
--
-- myOldConfig = defaultVimConfig
--   {
--
--    -- Keymap Configuration
--    defaultKm = defaultKm myOldConfig,
--
--    -- UI Configuration
--    -- Override the default UI as such:
--    startFrontEnd = startFrontEnd myOldConfig,
--                     -- Yi.UI.Vty.start -- for Vty
--    -- (can be overridden at the command line)
--    -- Options:
--    configUI = defaultUIConfig
--      {
--        configFontSize = Nothing,
--                         -- 'Just 10' for specifying the size.
--        configTheme = configTheme defaultUIConfig,-- darkBlueTheme ,
--
--                         -- configTheme defaultUIConfig,
--                      --darkBlueTheme  -- Change the color scheme here.
--
--        configWindowFill = '~' -- ' '
--                           -- '~'    -- Typical for Vim
--      }
--   }
--
--
-- --------------------------------------------------------------------------
-- -- Custom Events
-- --------------------------------------------------------------------------
--
-- increaseIndent :: BufferM()
-- increaseIndent =  modifyExtendedSelectionB Yi.Line $ mapLines ("  "++)
--
-- decreaseIndent :: BufferM()
-- decreaseIndent =  modifyExtendedSelectionB Yi.Line $ mapLines (drop 2)
--
-- prefIndent    :: Mode s -> Mode s
-- prefIndent m  =  m
--   { modeIndentSettings = IndentSettings
--       { expandTabs = True
--       , shiftWidth  = 2
--       , tabSize     = 2
--       }
--   }
--
-- mkInputMethod :: [(String,String)] -> Keymap
-- mkInputMethod xs = choice [pString i >> adjustPriority (negate (length i)) >>! savingInsertStringB o | (i,o) <- xs]
--
-- extraInput :: Keymap
-- extraInput = ctrl (char ']') ?>> mkInputMethod (greek ++ symbols)
--
-- -- need something better
-- unicodifySymbols :: BufferM ()
-- unicodifySymbols = modifyRegionB f =<< regionOfB unitViWORD
--   where f x = fromMaybe x $ lookup x (greek ++ symbols)
--
-- extendedVimKeymap :: Proto Vim.ModeMap
-- extendedVimKeymap = Vim.defKeymap `override` \super self -> super
--     { v_top_level = (deprioritize >> v_top_level super)
--                     <|> (char ',' ?>>! viWrite)
--                     <|> ((events $ map char "\\u") >>! unicodifySymbols)
--                     <|> ((events $ map char "\\c") >>! withModeB modeToggleCommentSelection)
--     , v_ins_char =
--             (deprioritize >> v_ins_char super)
--             -- On enter I always want to use the indent of previous line
--             -- TODO: If the line where the newline is to be inserted is inside a
--             -- block comment then the block comment should be "continued"
--             -- TODO: Ends up I'm trying to replicate vim's "autoindent" feature. This
--             -- should be made a function in Yi.
--             <|> ( spec KEnter ?>>! do
--                     insertB '\n'
--                     indentAsPreviousB
--                 )
--             -- I want softtabs to be deleted as if they are tabs. So if the
--             -- current col is a multiple of 4 and the previous 4 characters
--             -- are spaces then delete all 4 characters.
--             -- TODO: Incorporate into Yi itself.
--             <|> ( spec KBS ?>>! do
--                     c <- curCol
--                     line <- readRegionB =<< regionOfPartB Line Backward
--                     sw <- indentSettingsB >>= return . shiftWidth
--                     let indentStr = replicate sw ' '
--                         toDel = if (c `mod` sw) /= 0
--                                     then 1
--                                     else if indentStr `isPrefixOf` reverse line
--                                         then sw
--                                         else 1
--                     adjBlock (-toDel)
--                     replicateM_ toDel $ deleteB Character Backward
--                 )
--             -- On starting to write a block comment I want the close comment
--             -- text inserted automatically.
--             <|> choice
--                 [ pString open_tag >>! do
--                     insertN $ open_tag ++ " \n"
--                     indentAsPreviousB
--                     insertN $ " " ++ close_tag
--                     lineUp
--                  | (open_tag, close_tag) <-
--                     [ ("{-", "-}") -- Haskell block comments
--                     , ("/*", "*/") -- C++ block comments
--                     ]
--                 ]
--             <|> (adjustPriority (-1) >> extraInput)
--     , v_opts = (v_opts super) { tildeop = True }
--     , v_ex_cmds = exCmds [("b",
--                        withEditor . switchToBufferWithNameE,
--                        Just $ exHistInfixComplete' True matchingBufferNames)]
--     }
--
-- myConfig :: Config
-- myConfig = defaultVimConfig {
--     modeTable = modeTable defaultVimConfig,
--     defaultKm = v2KeymapSet $ myBindings,
--     configCheckExternalChangesObsessively = False,
--     configUI = (configUI defaultVimConfig)
--      {
--        configTheme = myTheme,
--        configWindowFill = '~'    -- Typical for Vim
--      }
-- }
--
-- myBindings :: (V2.EventString -> EditorM ()) -> [V2.VimBinding]
-- myBindings eval =
--        [
--          -- Tab traversal
--          nmap  "<C-h>" previousTabE
--        , nmap  "<C-l>" nextTabE
--        , nmap  "<C-l>" nextTabE
--
--          -- Press space to clear incremental search highlight
--        , nmap  " " (eval ":nohlsearch<CR>")
--
--        , nmap (leader "<C-a>") (getCountE >>= withBuffer0 . savingPointB . incrementNextNumberByB)
--        , nmap (leader "<C-x>") (getCountE >>= withBuffer0 . savingPointB . incrementNextNumberByB . negate)
--
-- --       , nmap (leader "t") testCall
-- --       , nmap (leader "c") (withBuffer0 testAJM)
--
--          -- Vimgolf
--        -- , nmap' (leader "vgs") (getChallenge vgChallenge)
--        -- , nmap' (leader "vge") (checkChallenge vgChallenge)
--
--          -- for times when you don't press shift hard enough
--        , nmap  ";" (eval ":")
--
--        , nmap  "<F3>" (withBuffer0 deleteTrailingSpaceB)
--        , nmap  "<F4>" (withBuffer0 moveToSol)
--        ]
--
-- vgChallenge :: String
-- vgChallenge = ""
