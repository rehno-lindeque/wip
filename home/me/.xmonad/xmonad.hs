{-# LANGUAGE FlexibleContexts, ConstraintKinds, RankNTypes #-}
 
import XMonad
import XMonad.Layout
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Util.EZConfig
import System.IO
 
main = do
    h <- xmobarProc
    xmonad
      . setupXmobar h
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
  `additionalKeysP` productivity 
  `additionalKeysP` browsers 
  `additionalKeysP` editors 
  `additionalKeysP`
  [ 
  -- ((mod4Mask, xK_q), spawn "sudo killall trayer" >> restart "xmonad" True)
  -- ((mod4Mask, xK_b), sendMessage ToggleStruts)
  ]
  where
    productivity =
      [ ("M-p", spawn "dmenu_run -fn 16 -nb '#333' -l 15 -b") -- dmenu is a quick launcher
      -- , ("M-p", spawn "yeganesh -x -- -fn 16 -nb '#333' -l 10 -b") -- yeganesh runs dmenu, showing popular selections first 
      --                                                              -- another set of possible flags: yeganesh -x -- -fn '-*-terminus-*-r-normal-*-*-120-*-*-*-*-iso8859-*'
      -- , ("M-S-P", spawn "gmrun")   -- gmrun 
      , ("M-S-v", spawn "chromium-browser --new-window https://github.com/begriffs/haskell-vim-now#keybindings-and-commands") -- vim haskell cheatsheet
      ]
    browsers =
      [ ("M-c", spawn "chromium")
      ]
    editors =  
      [ ("M-e", spawn "emacs")
      , ("M-s", spawn "sublime")
      , ("M-y", spawn "yi")
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
      --, ("M-j", windows W.focusDown)
      --, ("M-k", windows W.focusUp  )
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

myConfig = desktopConfig -- gnomeConfig


type SetupCfg_ = 
  ( LayoutClass l Window
  , Read (l Window)
  ) 
  => XConfig l
  -> XConfig l

-- type MyLayout  = Choose Tall (Choose (Mirror Tall) Full) 
-- type SetupCfg_ = XConfig MyLayout -> XConfig MyLayout

-- myMisc :: SetupCfg_
myMisc cfg = cfg
  { terminal = "gnome-terminal" -- "urxvt"
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

-- myLayout :: SetupCfg_
myLayout cfg = cfg 
  { layoutHook = tiled ||| Mirror tiled ||| Full
  }
  where
    -- default tiling algorithm partitions screen into two panes
    tiled = Tall nmaster delta ratio
    -- number of windows in the master pane
    nmaster = 1
    -- default proportion of screen occupied by master pane
    ratio = 2/3      
    -- percent of screen to increment when resizing
    delta = 5 / 100

xmobarProc :: IO Handle            
xmobarProc = spawnPipe "/run/current-system/sw/bin/xmobar $HOME/.xmobar/xmobarrc"

setupXmobar h cfg = cfg 
  { manageHook = manageDocks <+> manageHook cfg
  , layoutHook = avoidStruts $ layoutHook cfg
  , logHook = dynamicLogWithPP xmobarPP
    { ppOutput = hPutStrLn h
    , ppTitle = xmobarColor "black" "" . shorten 50
    , ppLayout = const "" -- to disable the layout info on xmobar
    }
  }


startup :: X ()
startup = do
  -- spawn "dropbox start"
  -- spawn "trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 10 --height 25"
  return ()

