{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# OPTIONS_GHC -Wno-partial-type-signatures #-}

module Main (main) where

import Control.Exception (bracket_)
import Control.Monad.Catch (catchAll)
import System.Exit
import System.Process (readProcessWithExitCode, system)
import XMonad
import XMonad.Actions.OnScreen
import XMonad.Actions.ToggleFullFloat
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Spacing (spacingWithEdge)
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Pass
import XMonad.Util.EZConfig (mkKeymap)
import XMonad.Util.ExtensibleState qualified as XS

import DBus qualified as D
import DBus.Client qualified as D

import Control.Monad (forM_, join, unless, when)
import Data.Foldable (toList)
import Data.List (find)
import Data.Map qualified as M
import Data.Maybe (isJust)
import Data.Ratio ((%))
import Data.Set qualified as S
import Graphics.X11.Xrandr (xrrGetOutputInfo, xrrGetScreenResourcesCurrent, xrr_oi_connection, xrr_oi_name, xrr_sr_outputs)
import Options.Applicative qualified as O
import System.Environment (setEnv)
import XMonad.Actions.DynamicWorkspaces (addHiddenWorkspace, removeEmptyWorkspaceByTag)
import XMonad.Actions.GridSelect (runSelectedAction)
import XMonad.Hooks.Rescreen (addAfterRescreenHook, addRandrChangeHook)
import XMonad.StackSet qualified as W

withModifiers :: [a -> a] -> a -> a
withModifiers fs c = foldl (\c' f -> f c') c fs

defaults :: Bool -> Config -> D.Client -> XConfig _
defaults hasSplitKbKeyboard config dbus =
    withModifiers
        [ ewmh
        , ewmhFullscreen
        , toggleFullFloatEwmhFullscreen
        , docks
        , withSB (polybar dbus)
        , withDisplays config.displayConfig
        ]
        def
            { -- simple stuff
              terminal = config.terminalEmulator
            , focusFollowsMouse = True
            , clickJustFocuses = False
            , borderWidth = 1
            , modMask = mod4Mask
            , workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
            , normalBorderColor = "#dddddd"
            , focusedBorderColor = "#ff0000"
            , -- key bindings
              keys = keyBindings
            , mouseBindings = mouseBindings
            , -- hooks, layouts
              layoutHook = layout
            }
  where
    keyBindings = \c ->
        M.insert (passthroughKey c.modMask) togglePassthrough $
            mkKeymap c $
            [ ("M-S-<Return>", spawn config.terminalEmulator)
            , ("M-S-p", spawn (config.rofi <> " -modi drun,window,ssh -show drun -show-icons"))
            , ("M-S-l", spawn config.screenLocker)
            , -- Layout management:
              ("M-<Space>", sendMessage NextLayout)
            , ("M-S-<Space>", setLayout $ c.layoutHook)
            , ("M-h", sendMessage Shrink)
            , ("M-l", sendMessage Expand)
            , ("M-,", sendMessage (IncMasterN 1))
            , ("M-.", sendMessage (IncMasterN (-1)))
            , -- Window management:
              ("M-S-c", kill)
            , ("M-n", refresh)
            , ("M-j", windows W.focusDown)
            , ("M-k", windows W.focusUp)
            , ("M-m", windows W.focusMaster)
            , ("M-<Return>", windows W.swapMaster)
            , ("M-S-j", windows W.swapDown)
            , ("M-S-k", windows W.swapUp)
            , ("M-t", withFocused $ windows . W.sink)
            , ("M-f", withFocused toggleFullFloat)
            , -- Screenshotter (flameshot):
              ("<Print>", spawn (config.flameshot <> " gui"))
            , -- Pass integration:
              ("M-s", passPrompt myXPConfig)
            , ("M-C-s", passEditPrompt myXPConfig)
            , ("M-S-s", passGeneratePrompt myXPConfig)
            , ("M-C-S-s", passRemovePrompt myXPConfig)
            , -- On-screen keyboard
              ("M-o", spawn config.onboard)
            , -- Volume and brightness (feedback via dunst):
              ("<XF86AudioRaiseVolume>", spawn (config.volumeControl <> " up"))
            , ("<XF86AudioLowerVolume>", spawn (config.volumeControl <> " down"))
            , ("<XF86AudioMute>", spawn (config.volumeControl <> " mute"))
            , ("<XF86AudioMicMute>", spawn (config.volumeControl <> " mic-mute"))
            , ("<XF86MonBrightnessUp>", spawn (config.brightnessControl <> " up"))
            , ("<XF86MonBrightnessDown>", spawn (config.brightnessControl <> " down"))
            , -- Network menu and airplane mode:
              ("M-S-n", spawn config.networkMenu)
            , ("<XF86Favorites>", spawn config.networkMenu) -- the star key on the ThinkPad
            , ("M-<XF86Favorites>", spawn config.bluetoothMenu)
            , -- Remote desktops (the keyboard passthrough toggle is inserted above):
              ("M-S-v", spawn config.remoteMenu)
            , ("M-S-a", spawn config.airplaneMode)
            , ("M-<Control_R>", spawn config.touchpadToggle)
            ]
                ++
                -- External display menu, plus bindings for the dynamic workspace
                -- "0" it creates. View and shift ignore unknown tags, so these are
                -- no-ops while "0" does not exist.
                concat
                    [ [ ("<XF86Display>", displayMenu c')
                      , ("M-0", windows (viewOnScreen 0 "0"))
                      , ("M-C-0", windows (viewOnScreen 1 "0"))
                      , ("M-C-S-0", windows (W.greedyView "0"))
                      , ("M-" <> workspaceZeroMoveKey, windows (W.shift "0"))
                      ]
                    | c' <- toList config.displayConfig
                    ]
                ++
                -- mod-[1..9], Switch to workspace N
                [ ("M-" <> m <> k, windows (f i))
                | (i, k) <- zip c.workspaces [[d] | d <- "123456789"]
                , (f, m) <-
                    [ (viewOnScreen 0, "")
                    , (viewOnScreen 1, "C-")
                    , (W.greedyView, "C-S-")
                    ]
                ]
                ++ [ ("M-" <> k, windows $ W.shift i)
                   | (i, k) <- zip c.workspaces workspaceMoveKeys
                   ]
                ++ [ ("M-" <> m <> k, screenWorkspace sc >>= flip whenJust (windows . f))
                   | (k, sc) <- zip ["w", "e", "r"] [0 ..]
                   , (f, m) <- [(W.view, ""), (W.shift, "S-")]
                   ]

    -- XMonad Prompt config for pass integration.
    myXPConfig :: XPConfig
    myXPConfig =
        def
            { searchPredicate = fuzzyMatch
            , sorter = fuzzySort
            }

    -- For moving windows to different workspaces on my split keyboard,
    -- a special mapping is required, due to a different keyboard layout:
    workspaceMoveKeys
        | hasSplitKbKeyboard = ["S-^", "S-3", "M5-n", "M5-x", "M5-y", "S-4", "M5-e", "M5-v", "M5-b"]
        | otherwise = ["S-" <> [k] | k <- ['1' .. '9']]
    workspaceZeroMoveKey
        | hasSplitKbKeyboard = "M5-4"
        | otherwise = "S-0"

    mouseBindings = \c ->
        M.fromList
            -- mod-button1, Set the window to floating mode and move by dragging
            [
                ( (c.modMask, button1)
                , ( \w ->
                        focus w
                            >> mouseMoveWindow w
                            >> windows W.shiftMaster
                  )
                )
            , -- mod-button2, Raise the window to the top of the stack
              ((c.modMask, button2), (\w -> focus w >> windows W.shiftMaster))
            , -- mod-button3, Set the window to floating mode and resize by dragging

                ( (c.modMask, button3)
                , ( \w ->
                        focus w
                            >> mouseResizeWindow w
                            >> windows W.shiftMaster
                  )
                )
            ]

    layout =
        -- 5 px of space around every window and along the screen edge, and no
        -- border when it would not tell you anything: a single window on the
        -- screen, or a floating window covering the whole screen (fullscreen).
        avoidStruts . smartBorders . spacingWithEdge 5 $
            Tall 1 (3 % 100) (1 % 2)
                ||| ThreeColMid 1 (3 % 100) (1 % 2)
                ||| Full
                ||| simpleTabbed

data DisplayConfig = DisplayConfig
    { xrandr :: !FilePath
    , internalDisplay :: !String
    , externalDisplay :: !String
    }
    deriving (Eq, Show)

data Config = Config
    { terminalEmulator :: !FilePath
    , rofi :: !FilePath
    , flameshot :: !FilePath
    , onboard :: !FilePath
    , screenLocker :: !FilePath
    , volumeControl :: !FilePath
    , brightnessControl :: !FilePath
    , networkMenu :: !FilePath
    , airplaneMode :: !FilePath
    , bluetoothMenu :: !FilePath
    , remoteMenu :: !FilePath
    , touchpadToggle :: !FilePath
    , displayConfig :: !(Maybe DisplayConfig)
    }
    deriving (Eq, Show)

-- | A path option with a default, as used for every external tool.
pathOption :: String -> Char -> String -> String -> O.Parser FilePath
pathOption long short defaultPath help =
    O.strOption
        ( O.long long
            <> O.short short
            <> O.metavar "PATH"
            <> O.value defaultPath
            <> O.showDefault
            <> O.help help
        )

parser :: O.Parser Config
parser =
    Config
        <$> pathOption "terminal-emulator" 't' "kitty" "Path to the terminal emulator to use."
        <*> pathOption "rofi" 'r' "rofi" "Path to rofi."
        <*> pathOption "flameshot" 'f' "flameshot" "Path to flameshot."
        <*> pathOption "onboard" 'o' "onboard" "Path to onboard."
        <*> pathOption "screen-locker" 'l' "xlock" "Path to screen locker."
        <*> pathOption "volume-control" 'v' "xmonad-volume" "Path to the volume control script (up|down|mute|mic-mute)."
        <*> pathOption "brightness-control" 'b' "xmonad-brightness" "Path to the brightness control script (up|down)."
        <*> pathOption "network-menu" 'n' "networkmanager_dmenu" "Path to the network menu."
        <*> pathOption "airplane-mode" 'a' "xmonad-airplane-mode" "Path to the airplane mode toggle script."
        <*> pathOption "bluetooth-menu" 'B' "rofi-bluetooth" "Path to the bluetooth menu."
        <*> pathOption "remote-menu" 'R' "xmonad-remote" "Path to the remote desktop menu."
        <*> pathOption "touchpad-toggle" 'T' "xmonad-touchpad" "Path to the touchpad toggle script."
        <*> O.optional
            ( DisplayConfig
                <$> pathOption "xrandr" 'x' "xrandr" "Path to xrandr."
                <*> O.strOption
                    ( O.long "internal-display"
                        <> O.short 'i'
                        <> O.metavar "NAME"
                        <> O.help "Name of the internal display."
                    )
                <*> O.strOption
                    ( O.long "external-display"
                        <> O.short 'e'
                        <> O.metavar "NAME"
                        <> O.help "Name of the external display."
                    )
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

withDisplays :: Maybe DisplayConfig -> XConfig l -> XConfig l
withDisplays (Just displayConfig) =
    addRandrChangeHook (displayChangeHook displayConfig)
        . addAfterRescreenHook syncWorkspaces
        . (\c -> c{startupHook = c.startupHook <> displayChangeHook displayConfig})
withDisplays Nothing = id

data DisplayMode = Internal | Mirrored | Extended
    deriving (Eq, Show)

instance ExtensionClass DisplayMode where
    initialValue = Internal

newtype ExternalConnected = ExternalConnected Bool
    deriving (Eq, Show)

instance ExtensionClass ExternalConnected where
    initialValue = ExternalConnected False

connectedOutputs :: X (S.Set String)
connectedOutputs = do
    dpy <- asks display
    root <- asks theRoot
    io $ do
        mres <- xrrGetScreenResourcesCurrent dpy root
        case mres of
            Nothing -> pure S.empty
            Just res -> do
                infos <- mapM (xrrGetOutputInfo dpy res) (xrr_sr_outputs res)
                pure $
                    S.fromList
                        [xrr_oi_name i | Just i <- infos, xrr_oi_connection i == xRR_Connected]

displayChangeHook :: DisplayConfig -> X ()
displayChangeHook displayConfig = do
    now <- S.member displayConfig.externalDisplay <$> connectedOutputs
    ExternalConnected before <- XS.get
    when (now /= before) $ do
        XS.put (ExternalConnected now)
        if now then displayMenu displayConfig else externalGone displayConfig

displayMenu :: DisplayConfig -> X ()
displayMenu displayConfig = do
    -- GridSelect draws on the focused screen. Focus the primary one first;
    -- it is screen 0, since every xrandr call marks the internal display
    -- as primary. Restore the previously focused workspace afterwards.
    previous <- gets (W.currentTag . windowset)
    screenWorkspace 0 >>= mapM_ (windows . W.view)
    runSelectedAction
        def
        [ ("Nur internes Display", internalOnly displayConfig)
        , ("Spiegeln (1920x1080)", mirror "1920x1080")
        , ("Spiegeln (1280x720)", mirror "1280x720")
        , ("Erweitern (1920x1080)", extend "1920x1080")
        , ("Erweitern (1280x720)", extend "1280x720")
        ]
    windows (W.view previous)
  where
    mirror res =
        switchTo
            displayConfig
            Mirrored
            [ "--output"
            , displayConfig.internalDisplay
            , "--primary"
            , "--mode"
            , res
            , "--output"
            , displayConfig.externalDisplay
            , "--mode"
            , res
            , "--same-as"
            , displayConfig.internalDisplay
            ]
    extend res =
        switchTo
            displayConfig
            Extended
            [ "--output"
            , displayConfig.internalDisplay
            , "--primary"
            , "--auto"
            , "--output"
            , displayConfig.externalDisplay
            , "--mode"
            , res
            , "--right-of"
            , displayConfig.internalDisplay
            ]

-- | Switch the external output off and put the internal one back to its
-- preferred (native) mode. Used both from the menu and on unplug.
internalOnly :: DisplayConfig -> X ()
internalOnly displayConfig =
    switchTo
        displayConfig
        Internal
        [ "--output"
        , displayConfig.internalDisplay
        , "--primary"
        , "--auto"
        , "--output"
        , displayConfig.externalDisplay
        , "--off"
        ]

externalGone :: DisplayConfig -> X ()
externalGone = internalOnly

-- | Run xrandr and record the new mode only if it succeeded, so a failed
-- switch (e.g. a mode the display does not offer) leaves the state alone.
switchTo :: DisplayConfig -> DisplayMode -> [String] -> X ()
switchTo displayConfig mode args = do
    ok <- runXrandr displayConfig args
    when ok (XS.put mode)

-- | Synchronous xrandr call. xmonad reaps child processes through its own
-- SIGCHLD handler, so the handlers are removed for the duration of the call;
-- otherwise waiting for the child fails even when xrandr succeeded.
runXrandr :: DisplayConfig -> [String] -> X Bool
runXrandr displayConfig args = io $ do
    (rc, _, err) <-
        bracket_ uninstallSignalHandlers installSignalHandlers $
            readProcessWithExitCode displayConfig.xrandr args ""
                `catchAll` \e -> pure (ExitFailure 1, "", show e)
    case rc of
        ExitSuccess -> pure True
        ExitFailure _ -> do
            putStrLn ("xrandr " <> unwords args <> " failed: " <> err)
            pure False

syncWorkspaces :: X ()
syncWorkspaces = do
    mode <- XS.get
    ws <- gets windowset
    let zero = find ((== "0") . W.tag) (W.workspaces ws)
        exists = isJust zero
    case mode of
        Extended ->
            -- Create "0" once, and show it on the second screen. This runs after
            -- rescreen, so screen 1 exists by now.
            unless exists $ do
                addHiddenWorkspace "0"
                windows (viewOnScreen 1 "0")
        _ ->
            when exists $ do
                let wins = maybe [] (W.integrate' . W.stack) zero
                windows $ \s -> foldr (W.shiftWin "1") s wins
                removeEmptyWorkspaceByTag "0"

------------------------------------------------------------------------
-- Keyboard passthrough: hand every key, Super combinations included, to
-- the focused window (remote desktops, virtual machines). Only the toggle
-- key itself stays grabbed while it is active.

-- | The toggle chord, given the configured modifier. Used both for the key
-- binding and for the grab that stays active during passthrough.
passthroughKey :: KeyMask -> (KeyMask, KeySym)
passthroughKey modm = (modm, xK_Escape)

newtype Passthrough = Passthrough Bool

instance ExtensionClass Passthrough where
    initialValue = Passthrough False

togglePassthrough :: X ()
togglePassthrough = do
    Passthrough active <- XS.get
    dpy <- asks display
    root <- asks theRoot
    conf <- asks config
    -- mkGrabs expands the key list the same way xmonad does at startup,
    -- including the NumLock and CapsLock variants.
    wanted <-
        if active
            then mkGrabs (M.keys (keys conf conf))
            else mkGrabs [passthroughKey (modMask conf)]
    io $ do
        ungrabKey dpy anyKey anyModifier root
        forM_ wanted $ \(m, kc) -> grabKey dpy kc m root True grabModeAsync grabModeAsync
    XS.put (Passthrough (not active))
    -- Re-run the log hook so the polybar indicator updates right away.
    join (asks (logHook . config))
    spawn $
        "notify-send -a xmonad -h string:x-dunst-stack-tag:Tastatur "
            <> if active then "'Tastatur: xmonad'" else "'Tastatur: Fenster'"

main :: IO ()
main = do
    setEnv "_JAVA_AWT_WM_NONREPARENTING" "1"
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
    let opath = D.objectPath_ "/org/xmonad/Log"
        iname = D.interfaceName_ "org.xmonad.Log"
        mname = D.memberName_ "Update"
        signal = D.signal opath iname mname
        body = [D.toVariant str]
     in D.emit dbus $ signal{D.signalBody = body}

polybar :: D.Client -> StatusBarConfig
polybar dbus =
    def{sbLogHook = dynamicLogWithPP polybarConfig}
  where
    polybarConfig =
        def
            { ppOutput = dbusOutput dbus
            , ppCurrent = withUnderline blue . withForeground blue
            , ppVisible = withUnderline darkGray . withForeground gray
            , ppUrgent = withUnderline darkGray . withForeground orange
            , ppHidden = withUnderline darkGray . withForeground gray
            , ppHiddenNoWindows = withUnderline darkGray . withForeground darkGray
            , ppTitle = withForeground purple . shorten 90
            , ppExtras = [passthroughIndicator]
            }
    withForeground c = wrap ("%{F" <> c <> "}") "%{F-}"
    withUnderline c = wrap ("%{u" <> c <> "}%{+u}") "%{-u}%{u-}"
    blue = "#2E9AFE"
    gray = "#7F7F7F"
    orange = "#ea4300"
    purple = "#9058c7"
    darkGray = "#3F3F3F"

-- | Polybar item while the keyboard passthrough is active.
passthroughIndicator :: X (Maybe String)
passthroughIndicator = do
    Passthrough active <- XS.get
    pure $
        if active
            then Just "%{T3}%{F#ea4300}\xF030C%{F-}%{T-}" -- nf-md-keyboard; GHC rejects the raw glyph
            else Nothing
