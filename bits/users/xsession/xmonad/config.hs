import XMonad
import XMonad.Core
import XMonad.ManageHook
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableTile (ResizableTall(..), MirrorResize(..))
import XMonad.Util.Run(spawnPipe, hPutStrLn)
import XMonad.Util.NamedScratchpad
import XMonad.Prompt
import XMonad.Prompt.Pass
import XMonad.Prompt.FuzzyMatch
import Data.List
import Data.Monoid
import Data.Ratio
import Control.Monad (liftM2)
import Control.Monad.Catch (catchAll)
import System.Exit
import System.Process (system)

import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String              as UTF8
import           XMonad.Hooks.FadeInactive             ( fadeInactiveLogHook )

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "kitty"
menuApplication = "rofi -modi drun,window,ssh -show drun -show-icons"
lockScreen      = "xsecurelock"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1:web","2:mail","3","4","5","6","7","8","9:slack"]

scratchpads = [
  NS "audio-control" "nix run m#pavucontrol" (className =? "Pavucontrol") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)),
  NS "htop" "kitty --class='my-scratchpad-htop' -T htop htop" (className =? "my-scratchpad-htop") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)),
  NS "nvidia-smi" "kitty --class='my-scratchpad-nvidia-smi' -T nividia-smi watch -n 5 nvidia-smi" (className =? "my-scratchpad-nvidia-smi") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)),
  NS "notes" "kitty --class='my-scratchpad-notes' -T notes nvim ~/Dokumente/Notizen/Main.org" (className =? "my-scratchpad-notes") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
              ]
-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys hasSplitKbKeyboard conf@(XConfig {modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

    -- launch rofi
    , ((modm .|. shiftMask, xK_p     ), spawn menuApplication)

    -- launch rofi
    , ((mod1Mask .|. shiftMask, xK_p     ), spawn menuApplication)

    -- launch lock screen
    , ((mod1Mask .|. shiftMask, xK_l ), spawn lockScreen)

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Control the space of the focused window
    , ((modm,               xK_a     ), sendMessage MirrorExpand)
    , ((modm,               xK_y     ), sendMessage MirrorShrink)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    , ((modm,               xK_f     ), toggleFull)
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Screenshot tool
    , ((0                 , xK_Print ), spawn "flameshot gui")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))

    , ((modm .|. controlMask .|. shiftMask, xK_a), namedScratchpadAction scratchpads "audio-control")
    , ((modm .|. controlMask .|. shiftMask, xK_n), namedScratchpadAction scratchpads "notes")
    , ((modm .|. controlMask .|. shiftMask, xK_h), namedScratchpadAction scratchpads "htop")
    , ((modm .|. controlMask .|. shiftMask, xK_g), namedScratchpadAction scratchpads "nvidia-smi")

    , ((modm                              , xK_s), passPrompt myXPConfig)
    , ((modm .|. controlMask              , xK_s), passEditPrompt myXPConfig)
    , ((modm                 .|. shiftMask, xK_s), passGeneratePrompt myXPConfig)
    , ((modm .|. controlMask .|. shiftMask, xK_s), passRemovePrompt myXPConfig)

    -- On-screen keyboard
    , ((modm                              , xK_o), spawn "onboard")

    -- Switch rotation
    , ((modm .|. controlMask              , xK_1), spawn "rotate 0")
    , ((modm .|. controlMask              , xK_2), spawn "rotate 90")
    , ((modm .|. controlMask              , xK_3), spawn "rotate 180")
    , ((modm .|. controlMask              , xK_4), spawn "rotate 270")

    -- Switch resolution for low-res projectors
    , ((modm .|. controlMask              , xK_8), spawn "projector lowres")
    , ((modm .|. controlMask              , xK_9), spawn "projector highres")
    , ((modm .|. controlMask              , xK_0), spawn "projector default")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    [((modm, k), windows $ W.greedyView i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]]
    ++

    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ W.shift i)
        | (i, (m, k)) <- zip (workspaces conf) (workspaceSwitchKeys hasSplitKbKeyboard)]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myXPConfig :: XPConfig
myXPConfig = def {
  searchPredicate = fuzzyMatch,
  sorter = fuzzySort
}

workspaceSwitchKeys hasSplitKbKeyboard
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

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = tiled ||| threeCol ||| Full ||| simpleTabbed
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = ResizableTall nmaster delta ratio [mainSlave, subSlave]
     threeCol = ThreeColMid nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

     mainSlave = 2/3
     subSlave = 1/3

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
doLower :: ManageHook
doLower = ask >>= \w -> liftX $ withDisplay $ \dpy -> io (lowerWindow dpy w) >> mempty

myManageHook = composeOne
    [ className =? "xfreerdp"       -?> doFullFloat
    , className =? "Slack"          -?> doShift "9:slack"
    , className =? "my-scratchpad-notes" -?> doFloat
    , className =? "MPlayer"        -?> doFloat
    , className =? "Gimp"           -?> doFloat
    , className =? "steam_app_356500"           -?> doFloat
    , resource  =? "desktop_window" -?> doIgnore
    , resource  =? "kdesktop"       -?> doIgnore
    ]
    -- where viewShift = doF . liftM2 (.) W.greedyView W.shift

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = ewmhDesktopsEventHook

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = setWMName "LG3D"

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults hasSplitKbKeyboard = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys hasSplitKbKeyboard,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = namedScratchpadManageHook scratchpads <> myManageHook,
        handleEventHook    = myEventHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch rofi",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]

main :: IO ()
main = mkDbusClient >>= main'

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
        
main' :: D.Client -> IO ()
main' dbus = do
  hasSplitkb <- detectSplitKbKeyboard
  let d = defaults hasSplitkb
  xmonad $ ewmh $ docks $ d
        { modMask = mod4Mask
        , terminal = "kitty"
        , manageHook = manageDocks <+> manageHook d
        , layoutHook = smartBorders $ avoidStruts $ spacing 10 $ myLayout
        , handleEventHook = handleEventHook d <+> fullscreenEventHook
        , logHook = myPolybarLogHook dbus
        }

ppCurrentColor = "#ffffff"
ppVisibleColor = "#cccccc"
ppHiddenColor = "#999999"
ppTitleColor = ppVisibleColor
ppUrgentColor = "#ffcccc"

------------------------------------------------------------------------
-- Polybar settings (needs DBus client).
--
mkDbusClient :: IO D.Client
mkDbusClient = do
  dbus <- D.connectSession
  D.requestName dbus (D.busName_ "org.xmonad.log") opts
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
      body   = [D.toVariant $ UTF8.decodeString str]
  in  D.emit dbus $ signal { D.signalBody = body }

polybarHook :: D.Client -> PP
polybarHook dbus =
  let nonNSP :: String -> Maybe String
      nonNSP "NSP" = Nothing
      nonNSP s     = Just s
      toStr Nothing  = ""
      toStr (Just s) = s
      withForeground c = wrap ("%{F" <> c <> "}") "%{F-}"
      withUnderline c = wrap ("%{u" <> c <> "}%{+u}") "%{-u}%{u-}"
      blue   = "#2E9AFE"
      gray   = "#7F7F7F"
      orange = "#ea4300"
      purple = "#9058c7"
      darkGray = "#3F3F3F"
  in  def { ppOutput          = dbusOutput dbus
          , ppCurrent         = toStr . fmap (withUnderline blue . withForeground blue) . nonNSP
          , ppVisible         = toStr . fmap (withUnderline darkGray . withForeground gray) . nonNSP
          , ppUrgent          = toStr . fmap (withUnderline darkGray . withForeground orange) . nonNSP
          , ppHidden          = toStr . fmap (withUnderline darkGray . withForeground gray) . nonNSP
          , ppHiddenNoWindows = toStr . fmap (withUnderline darkGray  . withForeground darkGray) . nonNSP
          , ppTitle           = toStr . fmap (withForeground purple) . nonNSP . shorten 90
          }

myPolybarLogHook dbus = myLogHook <+> dynamicLogWithPP (polybarHook dbus)
myLogHook = fadeInactiveLogHook 0.9

--Looks to see if focused window is floating and if it is the places it in the stack
--else it makes it floating but as full screen
toggleFull = withFocused (\windowId -> do
    { floats <- gets (W.floating . windowset);
        if windowId `M.member` floats
        then withFocused $ windows . W.sink
        else withFocused $ windows . (flip W.float $ W.RationalRect 0 0 1 1) })
