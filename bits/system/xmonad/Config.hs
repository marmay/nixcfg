{-# LANGUAGE OverloadedRecordDot, PartialTypeSignatures #-}
{-# OPTIONS_GHC -Wno-partial-type-signatures #-}

module Main (main) where

import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Prompt
import XMonad.Prompt.Pass
import XMonad.Prompt.FuzzyMatch
import XMonad.Actions.OnScreen
import XMonad.Actions.ToggleFullFloat
import Control.Monad.Catch (catchAll)
import System.Exit
import System.Process (system)

import qualified DBus as D
import qualified DBus.Client as D

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Options.Applicative qualified as O
import Data.Ratio ((%))
import System.Environment (setEnv)

defaults :: Bool -> Config -> D.Client -> XConfig _
defaults hasSplitKbKeyboard config dbus =
  ewmh
  $ ewmhFullscreen
  $ toggleFullFloatEwmhFullscreen
  $ docks
  $ withSB (polybar dbus)
  $ def {
      -- simple stuff
        terminal           = config.terminalEmulator
      , focusFollowsMouse  = True
      , clickJustFocuses   = False
      , borderWidth        = 1
      , modMask            = mod4Mask
      , workspaces         = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
      , normalBorderColor  = "#dddddd"
      , focusedBorderColor = "#ff0000"

      -- key bindings
      , keys               = keyBindings
      , mouseBindings      = mouseBindings

      -- hooks, layouts
      , layoutHook         = layout
    }
  where
    keyBindings = \c -> M.fromList $
      [ ((c.modMask .|. shiftMask, xK_Return), spawn config.terminalEmulator )
      , ((c.modMask .|. shiftMask, xK_p     ), spawn (config.rofi <> " -modi drun,window,ssh -show drun -show-icons"))
      , ((c.modMask .|. shiftMask, xK_l     ), spawn config.screenLocker )

      -- Layout management:
      , ((c.modMask              , xK_space ), sendMessage NextLayout)
      , ((c.modMask .|. shiftMask, xK_space ), setLayout $ c.layoutHook)
      , ((c.modMask              , xK_h     ), sendMessage Shrink)
      , ((c.modMask              , xK_l     ), sendMessage Expand)
      , ((c.modMask              , xK_comma ), sendMessage (IncMasterN 1))
      , ((c.modMask              , xK_period), sendMessage (IncMasterN (-1)))

      -- Window management:
      , ((c.modMask .|. shiftMask, xK_c     ), kill)
      , ((c.modMask              , xK_n     ), refresh)
      , ((c.modMask              , xK_j     ), windows W.focusDown)
      , ((c.modMask              , xK_k     ), windows W.focusUp  )
      , ((c.modMask              , xK_m     ), windows W.focusMaster  )
      , ((c.modMask              , xK_Return), windows W.swapMaster)
      , ((c.modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
      , ((c.modMask .|. shiftMask, xK_k     ), windows W.swapUp    )
      , ((c.modMask              , xK_t     ), withFocused $ windows . W.sink)
      , ((c.modMask              , xK_f     ), withFocused toggleFullFloat)

      -- Screenshotter (flameshot):
      , ((0                      , xK_Print ), spawn (config.flameshot <> " gui"))

      -- Pass integration:
      , ((c.modMask                              , xK_s), passPrompt myXPConfig)
      , ((c.modMask .|. controlMask              , xK_s), passEditPrompt myXPConfig)
      , ((c.modMask                 .|. shiftMask, xK_s), passGeneratePrompt myXPConfig)
      , ((c.modMask .|. controlMask .|. shiftMask, xK_s), passRemovePrompt myXPConfig)

      -- On-screen keyboard
      , ((c.modMask                              , xK_o), spawn config.onboard)
      ]
      ++
      -- mod-[1..9], Switch to workspace N
      [ ((m .|. c.modMask, k), windows (f i))
        | (i, k) <- zip c.workspaces ([xK_1 .. xK_9] ++ [xK_0])
        , (f, m) <- [ (viewOnScreen 0, 0)
                    , (viewOnScreen 1, controlMask)
                    , (W.greedyView, controlMask .|. shiftMask) ]
      ]
      ++
      [((m .|. c.modMask, k), windows $ W.shift i)
          | (i, (m, k)) <- zip c.workspaces workspaceMoveKeys]
      ++
      [((m .|. c.modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
          | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
          , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    -- XMonad Prompt config for pass integration.
    myXPConfig :: XPConfig
    myXPConfig = def {
      searchPredicate = fuzzyMatch,
      sorter = fuzzySort
    }

    -- For moving windows to different workspaces on my split keyboard,
    -- a special mapping is required, due to a different keyboard layout:
    workspaceMoveKeys
      | hasSplitKbKeyboard = [ (shiftMask, xK_asciicircum)
                             , (shiftMask, xK_3)
                             , (mod5Mask, xK_n)
                             , (mod5Mask, xK_x)
                             , (mod5Mask, xK_v)
                             , (shiftMask, xK_4)
                             , (mod5Mask, xK_e)
                             , (mod5Mask, xK_v)
                             , (mod5Mask, xK_b)
                             ] 
      | otherwise =          [ (shiftMask, k) | k <- [xK_1 .. xK_9] ]

    mouseBindings = \c -> M.fromList
      -- mod-button1, Set the window to floating mode and move by dragging
      [ ((c.modMask, button1), (\w -> focus w >> mouseMoveWindow w
                                         >> windows W.shiftMaster))
      -- mod-button2, Raise the window to the top of the stack
      , ((c.modMask, button2), (\w -> focus w >> windows W.shiftMaster))

      -- mod-button3, Set the window to floating mode and resize by dragging
      , ((c.modMask, button3), (\w -> focus w >> mouseResizeWindow w
                                         >> windows W.shiftMaster))
      ]

    layout = avoidStruts $
          Tall 1 (3 % 100) (1 % 2)
      ||| ThreeColMid 1 (3 % 100) (1 % 2)
      ||| Full
      ||| simpleTabbed

data Config = Config
  { terminalEmulator :: !FilePath
  , rofi :: !FilePath
  , flameshot :: !FilePath
  , onboard :: !FilePath
  , screenLocker :: !FilePath
  } deriving (Eq, Show)

parser :: O.Parser Config
parser =
  Config
    <$> O.strOption
      ( O.long "terminal-emulator"
      <> O.short 't'
      <> O.metavar "PATH"
      <> O.value "kitty"
      <> O.showDefault
      <> O.help "Path to the terminal emulator to use."
      )
    <*> O.strOption
      ( O.long "rofi"
      <> O.short 'r'
      <> O.metavar "PATH"
      <> O.value "rofi"
      <> O.showDefault
      <> O.help "Path to rofi."
      )
    <*> O.strOption
      ( O.long "flameshot"
      <> O.short 'f'
      <> O.metavar "PATH"
      <> O.value "flameshot"
      <> O.showDefault
      <> O.help "Path to flameshot."
      )
    <*> O.strOption
      ( O.long "onboard"
      <> O.short 'o'
      <> O.metavar "PATH"
      <> O.value "onboard"
      <> O.showDefault
      <> O.help "Path to onboard."
      )
    <*> O.strOption
      ( O.long "screen-locker"
      <> O.short 'l'
      <> O.metavar "PATH"
      <> O.value "xlock"
      <> O.showDefault
      <> O.help "Path to screen locker."
      )

parserInfo :: O.ParserInfo Config
parserInfo = O.info parser O.fullDesc

detectSplitKbKeyboard :: IO Bool
detectSplitKbKeyboard =
  do
    testRc <- system "xinput list 'splitkb.com Aurora Sofle v2 rev1' 2>/dev/null"
    let rc = testRc == ExitSuccess
    putStrLn $ "Detection of splitkb.com keyboard: " ++ show rc
    return rc
  `catchAll` \e -> do
    putStrLn $ "Error while detecting splitkb.com keyboard: " ++ show e
    return False
        
main :: IO ()
main = do
  setEnv "_JAVA_ATW_WM_NONREPARENTING" "1"
  putStrLn "Running start hook to hit xmonad-session.target."
  spawn "/run/current-system/systemd/bin/systemctl --user --no-block start xmonad-session.target"
  dbus <- mkDbusClient
  config <- O.execParser parserInfo
  hasSplitkb <- detectSplitKbKeyboard
  directories <- getDirectories
  launch (defaults hasSplitkb config dbus) directories

------------------------------------------------------------------------
-- Polybar settings (needs DBus client).
--
mkDbusClient :: IO D.Client
mkDbusClient = do
  dbus <- D.connectSession
  _ <- D.requestName dbus (D.busName_ "org.xmonad.log") opts
  return dbus
 where
  opts = [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str =
  let opath  = D.objectPath_ "/org/xmonad/Log"
      iname  = D.interfaceName_ "org.xmonad.Log"
      mname  = D.memberName_ "Update"
      signal = D.signal opath iname mname
      body   = [D.toVariant str]
  in  D.emit dbus $ signal { D.signalBody = body }

polybar :: D.Client -> StatusBarConfig
polybar dbus =
  def { sbLogHook = dynamicLogWithPP polybarConfig }
  where
    polybarConfig = def
      { ppOutput          = dbusOutput dbus
      , ppCurrent         = withUnderline blue . withForeground blue
      , ppVisible         = withUnderline darkGray . withForeground gray
      , ppUrgent          = withUnderline darkGray . withForeground orange
      , ppHidden          = withUnderline darkGray . withForeground gray
      , ppHiddenNoWindows = withUnderline darkGray  . withForeground darkGray
      , ppTitle           = withForeground purple . shorten 90
      }
    withForeground c = wrap ("%{F" <> c <> "}") "%{F-}"
    withUnderline c = wrap ("%{u" <> c <> "}%{+u}") "%{-u}%{u-}"
    blue   = "#2E9AFE"
    gray   = "#7F7F7F"
    orange = "#ea4300"
    purple = "#9058c7"
    darkGray = "#3F3F3F"
