{-# LANGUAGE ConstraintKinds       #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes            #-}
{-# LANGUAGE RecordWildCards       #-}
{-# LANGUAGE TypeSynonymInstances  #-}

import           Data.Ratio
import           Graphics.X11.ExtraTypes.XF86
import           System.IO
import           XMonad                       as XM
import qualified XMonad.Actions.CycleWS       as Actions (nextWS, prevWS,
                                                          shiftToNext,
                                                          shiftToPrev)
import qualified XMonad.Actions.WindowGo      as Actions
import qualified XMonad.Config.Desktop        as Config
import qualified XMonad.Config.Gnome          as Config
import qualified XMonad.Hooks.DynamicLog      as Hooks
import qualified XMonad.Hooks.ManageDocks     as Hooks
import qualified XMonad.Layout                as Layout
import qualified XMonad.Layout.Accordion      as Layout
import qualified XMonad.Layout.Fullscreen     as Layout
import           XMonad.Layout.LayoutModifier (LayoutModifier)
import qualified XMonad.Layout.LayoutModifier as Layout
import qualified XMonad.Layout.MagicFocus     as Layout
import qualified XMonad.Layout.NoBorders      as Layout
import qualified XMonad.StackSet              as Stack
import           XMonad.Util.EZConfig
import           XMonad.Util.Run

main = do
    -- h <- xmobarProc
    xmonad
      -- . setupXmobar h
      . myBorders
      . myKeys
      . myHooks
      . myLayout
      . myMisc
      $ myConfig

-- myKeys :: SetupCfg_
myKeys cfg = cfg
  { modMask = mod1Mask
  -- modMask = mod4Mask   -- super instead of alt (usually Windows key)
  -- modMask = lockMask   -- capslock instead of alt
  -- modMask = controlMask -- control instead of alt
  --
  }
  `additionalKeysP` navigation
  `additionalKeysP` productivity
  `additionalKeysP` browsers
  `additionalKeysP` editors
  -- `additionalKeysP` audio
  `additionalKeysP`
  [
  -- ((mod4Mask, xK_q), spawn "sudo killall trayer" >> restart "xmonad" True)
  -- ((mod4Mask, xK_b), sendMessage ToggleStruts)
  ]
  where
    -- This configuration tries to keep the layout somewhat stable in order to provide a consistent environment
    navigation =
      [ ("M-<Space>", sendMessage NextLayout)
      , ("M-S-j" , windows (Stack.swapDown) {->> sendMessage NextLayout-}) -- TODO ?
      , ("M-j"   , windows Stack.focusDown)
      , ("M-S-k" , windows (Stack.swapUp))
      , ("M-k"   , windows Stack.focusUp)
      , ("M-S-n" , windows (Stack.swapDown))
      , ("M-n"   , windows Stack.focusDown)
      , ("M-S-i" , windows (Stack.swapUp))
      , ("M-i"   , windows Stack.focusUp)
      , ("M-l"   , Actions.nextWS)
      , ("M-S-l" , Actions.shiftToNext)
      , ("M-h"   , Actions.prevWS)
      , ("M-S-h" , Actions.shiftToPrev)
      , ("M-o"   , Actions.nextWS)
      , ("M-S-o" , Actions.shiftToNext)
      , ("M-y"   , Actions.prevWS)
      , ("M-S-y" , Actions.shiftToPrev)
      ]
    productivity =
      [ ("M-p", spawn "dmenu_run -fn 16 -nb '#333' -l 15 -b") -- dmenu is a quick launcher
      -- , ("M-p", spawn "yeganesh -x -- -fn 16 -nb '#333' -l 10 -b") -- yeganesh runs dmenu, showing popular selections first
      --                                                              -- another set of possible flags: yeganesh -x -- -fn '-*-terminus-*-r-normal-*-*-120-*-*-*-*-iso8859-*'
      -- , ("M-S-P", spawn "gmrun")   -- gmrun
      -- , ("M-S-v", spawn "chromium-browser --new-window https://github.com/begriffs/haskell-vim-now#keybindings-and-commands") -- vim haskell cheatsheet
      ]
    browsers =
      [ ("M-b", Actions.raiseBrowser)
      -- ("M-c", spawn "chromium")
      ]
    editors =
      [ ("M-e", Actions.raiseEditor)
      -- , ("M-e", spawn "emacs")
      -- , ("M-s", Actions.runOrRaiseMaster "sublime" (className =? "sublime"))
      -- , ("M-y", Actions.runOrRaiseMaster "yi" (className =? "yi"))
      ]
    audio =
      [
      --  ("<XF86AudioLowerVolume>", spawn "amixer -q -D pulse sset Master 5%-")
      --, ("<XF86AudioMute>",        spawn "amixer -q -D pulse sset Master toggle")
      --, ("<XF86AudioRaiseVolume>", spawn "amixer -q -D pulse sset Master 5%+")
      --, ("<XF86AudioPlay>",        spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
      -- , ("<XF86AudioStop>",        spawn "spotify")
      -- , ("<XF86AudioPrev>",        spawn "spotify")
      -- , ("<XF86AudioNext>",        spawn "spotify")
      ]
      --, ("M-S-<Return>", spawn $ XMonad.terminal conf)
      --, ("M-C-<Return>", spawn "urxvt -e tmux attach")
      --, ("0-<Scroll_Lock>", spawn "gnome-screensaver-command -l")
      --, ("M-<Print>", spawn "gnome-screensaver-command -l")
      --, ("M-<Tab>", spawn "xfdesktop --windowlist")
      --, ("M-p", spawn "xfce4-appfinder -c")
      --, ("M-S-p", spawn "xfce4-appfinder -c")
      --, ("M-S-c", kill)
      --, ("M-<Space>", sendMessage NextLayout)
      --, ("M-S-space", setLayout $ XMonad.layoutHook conf)
      --, ("M-n", refresh)
      --, ("M-<Tab>", windows W.focusDown)
      --, ("M-<Down>", windows W.focusDown)
      --, ("M-<Up>", windows W.focusUp  )
      --, ("M-<Left>", windows W.focusUp)
      --, ("M-<Right>", windows W.focusDown)
      --, ("M-m", windows W.focusMaster  )
      --, ("M-S-m", spawn "multi-ssh")
      --, ("M-xK_Return", windows W.swapMaster)
      --, ("M-S-j", windows W.swapDown  )
      --, ("M-S-k", windows W.swapUp    )
      --, ("M-xK_h", sendMessage Shrink)
      --, ("M-xK_l", sendMessage Expand)
      --, ("M-xK_t", withFocused $ windows . W.sink)
      --, ("M-xK_comma", sendMessage (IncMasterN 1))
      --, ("M-xK_period", sendMessage (IncMasterN (-1)))
      --, ("M-C-q", io (exitWith ExitSuccess))
      --, ("M-S-q", spawn "xfce4-session-logout")
      --, ("M-xK_q", restart "xmonad" True)
      --, ("M-C-g", sendMessage $ ToggleGaps)
      --
      --, ("M-S-a", sendMessage MirrorShrink)
      --, ("M-S-z", sendMessage MirrorExpand)
      --, ("M-xK_a", sendMessage Shrink)
      --, ("M-xK_z", sendMessage Expand)
      --, ("M-C-S-<Right>", sendMessage $ Move R)
      --, ("M-C-S-<Left>", sendMessage $ Move L)
      --, ("M-C-S-<Up>", sendMessage $ Move U)
      --, ("M-C-S-<Down>", sendMessage $ Move D)

      -- -- mod4-[1..9] @@ Switch to window N
      -- [((modMask, k), focusNth i)
      --     | (i, k) <- zip [0 .. 8] [xK_1 ..]]

      -- -- [F1..F9], Switch to workspace N
      -- -- shift-[F1..F9], Move client to workspace N
      -- --
      -- [((m, k), windows $ f i)
      --
      --     | (i, k) <- zip (XMonad.workspaces conf) [xK_F1 .. xK_F9]
      --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)
      --     , (copy, shiftMask .|. C-)]]

myConfig = Config.desktopConfig -- Config.gnomeConfig


type SetupCfg_ = forall l.
  ( LayoutClass l Window
  , Read (l Window)
  )
  => XConfig l
  -> XConfig l

-- type MyLayout  = Choose Tall (Choose (Mirror Tall) Full)
-- type SetupCfg_ = XConfig MyLayout -> XConfig MyLayout

-- myMisc :: SetupCfg_
myMisc cfg = cfg
  { terminal = "sakura" -- "gnome-terminal" -- "urxvt"
  }

-- myBorders :: SetupCfg_
myBorders cfg = cfg
  { borderWidth = 2
  , normalBorderColor = "#000000"
  , focusedBorderColor = "#ffaa00"
  }


-- myHooks :: SetupCfg_
myHooks cfg = cfg
  { startupHook = startup
  -- , manageHook = manageDocks <+> manageHook defaultConfig
  -- , layoutHook = avoidStruts $ layoutHook defaultConfig
  }

data ExpandFocused a = ExpandFocused !(Ratio Dimension) deriving (Show, Read)

instance LayoutModifier ExpandFocused Window where
  pureModifier (ExpandFocused ratio) srect mst layout =
    (scaleStack mst, Nothing)
    where
      -- tuple operations
      fromIntegral2 :: (Integral i, Num n) => (i, i) -> (n, n)
      fromIntegral2 (a0, a1) = (fromIntegral a0, fromIntegral a1)

      sub2 :: Num n => (n, n) -> (n,n) -> (n, n)
      sub2 (a0,a1) (b0,b1) = (a0 - b0, a1 - b1)

      add2 :: Num n => (n, n) -> (n,n) -> (n, n)
      add2 (a0,a1) (b0,b1) = (a0 + b0, a1 + b1)

      min2 :: Ord o => (o, o) -> (o,o) -> (o, o)
      min2 (a0,a1) (b0,b1) = (min a0 b0, min a1 b1)

      max2 :: Ord o => (o, o) -> (o,o) -> (o, o)
      max2 (a0,a1) (b0,b1) = (max a0 b0, max a1 b1)

      -- Screen coordinates
      (x0, y0, w, h) = (rect_x srect, rect_y srect, rect_width srect, rect_height srect)
      (x1, y1)       = (x0 + fromIntegral w, y0 + fromIntegral h)
      delta          = (floor $ ratio * fromIntegral w, floor $ ratio * fromIntegral h)

      -- constrain rectangle to bounds
      constrainPoint (x,y) = min2 (x1,y1) (max2 (x0, y0) (x,y))

      -- constrain rectangle to bounds
      contrainRect Rectangle{..} =
        let (x,y) = min (x1, y1) (max (x0,y0) (rect_x, rect_y))
        in Rectangle
            { rect_x      = x
            , rect_y      = y
            , rect_width  = min rect_width  (max 0 (w - fromIntegral x))
            , rect_height = min rect_height (max 0 (h - fromIntegral y))
            }

      -- screen bounded subtraction / addition
      bsub :: (Ord n, Num n) => (n, n) -> (n,n) -> (n, n)
      bsub a b = max2 (fromIntegral2 (x0,y0)) (a `sub2` b)

      badd :: Integral i => (i, i) -> (i,i) -> (i, i)
      badd a b = min2 (fromIntegral2 (x1, y1)) (a `add2` b)

      -- Rectangle from top-left, bottom-right coordinates
      -- rectFromCoords tl br = uncurry (uncurry Rectangle $ fromIntegral2 tl) (fromIntegral2 $ br `sub2` tl)
      rectFromCoords tl br = uncurry (uncurry Rectangle $ fromIntegral2 tl) (fromIntegral2 $ br `sub2` tl)

      -- Expand, contract helpers
      expand d (win, r@Rectangle {..}) =
        let rxy = (rect_x, rect_y)
            rwh = (rect_width, rect_height)
        in  ( win
            -- , r
            , rectFromCoords
                (fromIntegral2 (rxy `bsub` d))
                ((rxy `add2` fromIntegral2 rwh) `badd` d)
            )
      contract :: (Integral num, Integral num') => (num,num) -> (num',num') -> (window, Rectangle) -> (window, Rectangle)
      contract (dx,dy) dir (win, r@Rectangle {..}) =
        let rxy = (rect_x, rect_y)
            rwh = (rect_width, rect_height)
        in  ( win
            , r -- TODO: adjust
            )

      -- Determine direction to shrink a window in using the coordinates of the focus window
      contractDirection :: Integral num => (num,num) -> (num,num) -> (window,Rectangle) -> (num,num)
      contractDirection f0@(fx0, fy0) f1@(fx1, fy1) (_,wr) =
        let w0@(wx0, wy0) = (rect_x wr, rect_y wr)
            w1@(wx1, wy1) = (wx0, wx1) `add2` fromIntegral2 (rect_width wr, rect_height wr)
        in (0, 0) -- TODO

      -- Scale the stack appropriately
      scaleStack Nothing                 = layout
      scaleStack (Just Stack.Stack {..}) =
        let (ups, foc:downs) = splitAt (length up) layout
            fr = snd foc
            f0@(fx0, fy0) = (rect_x fr, rect_y fr)
            f1@(fx1, fy1) = (fx0, fx1) `add2` fromIntegral2 (rect_width fr, rect_height fr)
            d = ( if fx0 > x0 && fx1 < x1 then fst delta else 2 * fst delta
                , if fy0 > y0 && fy1 < y1 then snd delta else 2 * snd delta
                )
        -- in map (contract d) ups ++ [foc] ++ map (contract d) downs
        -- in map (contract d <*> contractDirection f0 f1 _ _) ups ++ [expand d foc] ++ map (contract d <*> contractDirection f0 f1 _ _) downs
        in map (flip (contract d) <*> contractDirection f0 f1) ups ++ [expand d foc] ++ map (flip (contract d) <*> contractDirection f0 f1) downs

expandFocused :: Ratio Dimension -> l a -> Layout.ModifiedLayout ExpandFocused l a
expandFocused ratio = Layout.ModifiedLayout (ExpandFocused ratio)

-- myLayout :: SetupCfg_
myLayout cfg = cfg
  -- Swaps the windows around, which is annoying
  -- { layoutHook = magicFocus (Tall 1 (3/100) (1/2)) ||| tiled ||| Mirror tiled ||| Full
  -- , handleEventHook = Magic.promoteWarp
  { layoutHook = -- expandFocused (1 / 100)
                  (
                    tiled
                    {-||| Mirror tiled-}
                  )
                  ||| Layout.Accordion
                  ||| Layout.noBorders (Layout.fullscreenFull Layout.Full)
  }
  where
    -- default tiling algorithm partitions screen into two panes
    tiled = Tall nmaster delta ratio
    -- number of windows in the master pane
    nmaster = 1
    -- default proportion of screen occupied by master pane
    ratio = 2 / 3
    -- percent of screen to increment when resizing
    delta = 5 / 100

-- xmobarProc :: IO Handle
-- xmobarProc = spawnPipe "/run/current-system/sw/bin/xmobar $HOME/.xmobar/xmobarrc"

-- setupXmobar h cfg = cfg
--   { manageHook = Hooks.manageDocks <+> manageHook cfg
--   , layoutHook = Hooks.avoidStruts $ layoutHook cfg
--   , logHook = Hooks.dynamicLogWithPP Hooks.xmobarPP
--     { Hooks.ppOutput = hPutStrLn h
--     , Hooks.ppTitle = Hooks.xmobarColor "black" "" . Hooks.shorten 50
--     , Hooks.ppLayout = const "" -- to disable the layout info on xmobar
--     }
--   }


startup :: X ()
startup = do
  -- spawn "dropbox start"
  -- spawn "trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 10 --height 25"
  return ()

