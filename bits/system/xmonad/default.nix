{ config, lib, pkgs, nixosConfig, ... }:

let
  cfg = config.marmar.xmonad;
  displaysConfigured = cfg.displays.internal != null && cfg.displays.external != null;

  # Small helpers bound to keys in Config.hs. They carry their own
  # dependencies, so xmonad only needs their paths.
  volumeControl = pkgs.writeShellApplication {
    name = "xmonad-volume";
    runtimeInputs = [ pkgs.wireplumber pkgs.libnotify pkgs.gawk ];
    text = ''
      target=@DEFAULT_AUDIO_SINK@
      label=Lautstärke
      case "''${1:-}" in
        up)       wpctl set-volume -l 1.0 "$target" 5%+ ;;
        down)     wpctl set-volume "$target" 5%- ;;
        mute)     wpctl set-mute "$target" toggle ;;
        mic-mute) target=@DEFAULT_AUDIO_SOURCE@; label=Mikrofon
                  wpctl set-mute "$target" toggle ;;
        *)        echo "usage: $0 up|down|mute|mic-mute" >&2; exit 2 ;;
      esac
      # wpctl prints e.g. "Volume: 0.65" or "Volume: 0.47 [MUTED]".
      state=$(wpctl get-volume "$target")
      pct=$(awk '{ printf "%d", $2 * 100 }' <<< "$state")
      if [[ "$state" == *MUTED* ]]; then
        text="$label: stumm"
      else
        text="$label: $pct%"
      fi
      notify-send -a xmonad -h int:value:"$pct" -h string:x-dunst-stack-tag:"$label" "$text"
    '';
  };

  brightnessControl = pkgs.writeShellApplication {
    name = "xmonad-brightness";
    runtimeInputs = [ pkgs.brightnessctl pkgs.libnotify pkgs.coreutils ];
    text = ''
      case "''${1:-}" in
        up)   brightnessctl -q set 5%+ ;;
        down) brightnessctl -q --min-value=1 set 5%- ;;
        *)    echo "usage: $0 up|down" >&2; exit 2 ;;
      esac
      # Machine-readable output: device,class,current,percent,max
      pct=$(brightnessctl -m | cut -d, -f4 | tr -d %)
      notify-send -a xmonad -h int:value:"$pct" -h string:x-dunst-stack-tag:Helligkeit "Helligkeit: $pct%"
    '';
  };

  airplaneMode = pkgs.writeShellApplication {
    name = "xmonad-airplane-mode";
    runtimeInputs = [ pkgs.util-linux pkgs.gnugrep ];
    text = ''
      # Same effect as the hardware airplane key, which the kernel handles
      # through rfkill. NetworkManager follows rfkill. The notification comes
      # from the rfkill watcher service, so every way of toggling is announced.
      if LC_ALL=C rfkill --noheadings --output SOFT list wlan | grep -qx blocked; then
        rfkill unblock all
      else
        rfkill block all
      fi
    '';
  };

  rfkillNotify = pkgs.writeShellApplication {
    name = "xmonad-rfkill-notify";
    runtimeInputs = [ pkgs.util-linux pkgs.libnotify pkgs.gnugrep ];
    text = ''
      airplane() {
        if LC_ALL=C rfkill --noheadings --output SOFT list wlan | grep -qx blocked; then
          echo an
        else
          echo aus
        fi
      }
      # rfkill event replays the current state on start; seed 'last' so that
      # does not produce a notification at login.
      last=$(airplane)
      LC_ALL=C rfkill event | while read -r _; do
        state=$(airplane)
        if [ "$state" != "$last" ]; then
          notify-send -a xmonad -h string:x-dunst-stack-tag:Flugmodus "Flugmodus $state"
          last=$state
        fi
      done
    '';
  };

  # Notification look; the colours follow the polybar palette in Config.hs.
  dunstConfig = pkgs.writeText "dunstrc" ''
    [global]
    font = IosevkaTerm Nerd Font 11
    frame_width = 1
    frame_color = "#3F3F3F"
    corner_radius = 4
    progress_bar_height = 8
    progress_bar_frame_width = 0
    progress_bar_corner_radius = 4

    [urgency_low]
    background = "#1E1E1E"
    foreground = "#7F7F7F"
    highlight = "#7F7F7F"

    [urgency_normal]
    background = "#1E1E1E"
    foreground = "#DDDDDD"
    highlight = "#2E9AFE"

    [urgency_critical]
    background = "#1E1E1E"
    foreground = "#DDDDDD"
    frame_color = "#EA4300"
    highlight = "#EA4300"

    # Popups from the xmonad helper scripts (volume, brightness, airplane mode):
    [xmonad]
    appname = "xmonad"
    highlight = "#2E9AFE,#9058C7"
    timeout = 2
  '';

  # Bluetooth headset status for polybar, and a connect/disconnect toggle.
  # "The headset" is the first paired device BlueZ classifies as audio.
  headsetControl = pkgs.writeShellApplication {
    name = "xmonad-headset";
    runtimeInputs = [ pkgs.bluez pkgs.pulseaudio pkgs.libnotify pkgs.coreutils pkgs.gawk ];
    text = ''
      mac=""
      for m in $(bluetoothctl devices Paired | cut -d' ' -f2); do
        if [[ "$(bluetoothctl info "$m")" == *"Icon: audio-"* ]]; then
          mac=$m
          break
        fi
      done

      connected() {
        [ -n "$mac" ] && [[ "$(bluetoothctl info "$mac")" == *"Connected: yes"* ]]
      }

      # Active profile of the headset's card, e.g. a2dp-sink or headset-head-unit.
      profile() {
        LC_ALL=C pactl list cards | awk '/Name: bluez_card/ { p = 1 } p && /Active Profile:/ { print $3; exit }'
      }

      case "''${1:-}" in
        status)
          if connected; then
            case "$(profile)" in
              a2dp*)    echo "%{T3}󰋋%{T-}" ;;
              headset*) echo "%{T3}󰋎%{T-}" ;;
              *)        echo "%{T3}󰋋%{T-}" ;;
            esac
          else
            echo "%{T3}%{F#3F3F3F}󰋋%{F-}%{T-}"
          fi
          ;;
        toggle)
          if [ -z "$mac" ]; then
            notify-send -a xmonad -u critical "Kein Headset gekoppelt"
            exit 1
          fi
          name=$(bluetoothctl info "$mac" | awk -F': ' '/Alias:/ { print $2; exit }')
          if connected; then
            if bluetoothctl disconnect "$mac" >/dev/null; then
              notify-send -a xmonad "$name getrennt"
            fi
          elif bluetoothctl connect "$mac" >/dev/null; then
            notify-send -a xmonad "$name verbunden"
          else
            notify-send -a xmonad -u critical "$name: Verbindung fehlgeschlagen"
          fi
          ;;
        profile-toggle)
          card=$(LC_ALL=C pactl list cards | awk '/Name: bluez_card/ { print $2; exit }')
          if [ -z "$card" ] || ! connected; then
            notify-send -a xmonad -u critical "Kein Headset verbunden"
            exit 1
          fi
          # Remember the exact A2DP profile (codec) so that switching back
          # restores it instead of the generic default.
          memo="''${XDG_RUNTIME_DIR:-/tmp}/xmonad-headset-a2dp"
          current=$(profile)
          case "$current" in
            a2dp*)
              echo "$current" > "$memo"
              pactl set-card-profile "$card" headset-head-unit
              notify-send -a xmonad "Headset: HFP (Mikrofon)"
              ;;
            *)
              wanted=a2dp-sink
              if [ -r "$memo" ]; then
                wanted=$(cat "$memo")
              fi
              pactl set-card-profile "$card" "$wanted"
              notify-send -a xmonad "Headset: A2DP (Musik)"
              ;;
          esac
          ;;
        *)
          echo "usage: $0 status|toggle|profile-toggle" >&2
          exit 2
          ;;
      esac
    '';
  };

  # Enable/disable the touchpad; the TrackPoint is a separate device and
  # keeps working.
  touchpadToggle = pkgs.writeShellApplication {
    name = "xmonad-touchpad";
    runtimeInputs = [ pkgs.xinput pkgs.gnugrep pkgs.libnotify ];
    text = ''
      # xinput marks disabled devices with a leading "∼ " in its name list;
      # strip it, since the device is still addressed by its plain name.
      name=$(xinput list --name-only | grep -i -m1 touchpad || true)
      name=''${name#"∼ "}
      if [ -z "$name" ]; then
        notify-send -a xmonad -u critical "Kein Touchpad gefunden"
        exit 1
      fi
      props=$(xinput list-props "$name")
      if [[ "$props" =~ Device\ Enabled[^:]*:[[:space:]]*1 ]]; then
        xinput disable "$name"
        notify-send -a xmonad -h string:x-dunst-stack-tag:Touchpad "Touchpad aus"
      else
        xinput enable "$name"
        notify-send -a xmonad -h string:x-dunst-stack-tag:Touchpad "Touchpad an"
      fi
    '';
  };

  # NAS switch: mount or unmount the shares (nas.target, see nas_client.nix)
  # and report the state for polybar.
  nasToggle = pkgs.writeShellApplication {
    name = "xmonad-nas";
    runtimeInputs = [ pkgs.systemd pkgs.libnotify ];
    text = ''
      mounted() { systemctl is-active --quiet media-nas.mount; }
      case "''${1:-}" in
        status)
          if mounted; then
            echo "%{T3}󰒍%{T-}"
          else
            echo "%{T3}%{F#3F3F3F}󰒍%{F-}%{T-}"
          fi
          ;;
        toggle)
          if mounted; then
            if systemctl stop media-nas.mount; then
              notify-send -a xmonad -h string:x-dunst-stack-tag:NAS "NAS getrennt"
            else
              notify-send -a xmonad -u critical -h string:x-dunst-stack-tag:NAS "NAS: Trennen fehlgeschlagen"
            fi
          else
            notify-send -a xmonad -h string:x-dunst-stack-tag:NAS "NAS wird verbunden …"
            if systemctl start nas.target; then
              notify-send -a xmonad -h string:x-dunst-stack-tag:NAS "NAS verbunden"
            else
              notify-send -a xmonad -u critical -h string:x-dunst-stack-tag:NAS "NAS nicht erreichbar"
            fi
          fi
          ;;
        *)
          echo "usage: $0 status|toggle" >&2
          exit 2
          ;;
      esac
    '';
  };

  networkMenuConfig = pkgs.writeText "networkmanager-dmenu.ini" ''
    [dmenu]
    dmenu_command = ${lib.getExe pkgs.rofi} -dmenu -i
    rofi_highlight = True

    [editor]
    terminal = ${lib.getExe pkgs.kitty}
  '';

  networkMenu = pkgs.writeShellApplication {
    name = "xmonad-network-menu";
    runtimeInputs = [ pkgs.networkmanager_dmenu ];
    text = ''
      exec networkmanager_dmenu --config ${networkMenuConfig} "$@"
    '';
  };
in
{
  imports = [ ./remote.nix ];

  options = {
    marmar.xmonad = {
      enable = lib.mkEnableOption "xmonad";

      displays = {
        internal = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "eDP-1";
          description = ''
            RandR name of the built-in display. Together with `external`,
            enables the external display menu in xmonad.
          '';
        };

        external = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "HDMI-1";
          description = ''
            RandR name of the output an external display gets plugged into.
            Together with `internal`, enables the external display menu in xmonad.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.displays.internal == null) == (cfg.displays.external == null);
        message = "marmar.xmonad.displays: set both `internal` and `external`, or neither.";
      }
    ];

    environment.systemPackages = with pkgs; [
      kitty
      lato
      nerd-fonts.iosevka-term
      pass
      rofi
      flameshot
      onboard
      xlockmore
      libnotify # notify-send for the keyboard passthrough toggle in Config.hs
    ];

    # brightnessctl ships udev rules that let the video group write the backlight.
    services.udev.packages = [ pkgs.brightnessctl ];

    services = {
      xserver = {
        windowManager.xmonad = {
          enable = true;
          extraPackages = haskellPackages: [ haskellPackages.dbus ];
          enableContribAndExtras = true;
          config = ./Config.hs;
          xmonadCliArgs = [
            "--terminal-emulator=${pkgs.kitty}/bin/kitty"
            "--rofi=${pkgs.rofi}/bin/rofi"
            "--flameshot=${pkgs.flameshot}/bin/flameshot"
            "--onboard=${pkgs.onboard}/bin/onboard"
            "--screen-locker=${pkgs.xlockmore}/bin/xlock"
            "--volume-control=${lib.getExe volumeControl}"
            "--brightness-control=${lib.getExe brightnessControl}"
            "--network-menu=${lib.getExe networkMenu}"
            "--airplane-mode=${lib.getExe airplaneMode}"
            "--bluetooth-menu=${lib.getExe pkgs.rofi-bluetooth}"
            "--touchpad-toggle=${lib.getExe touchpadToggle}"
            "--nas-toggle=${lib.getExe nasToggle}"
          ] ++ lib.optionals displaysConfigured [
            "--xrandr=${lib.getExe pkgs.xrandr}"
            "--internal-display=${cfg.displays.internal}"
            "--external-display=${cfg.displays.external}"
          ];
        };
      };

      udisks2.enable = true;
    };

    systemd.user.targets.xmonad-session = {
      description = "xmonad session";
      documentation = [ "man:systemd.special(7)" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
    };

    systemd.user.services = {
      # Only run dunst for the xmonad session:
      xmonad-dunst = {
        enable = true;
        description = "dunst desktop notifications service";
        after = [ "xmonad-session.target" ];
        partOf = [ "xmonad-session.target" ];
        wantedBy = [ "xmonad-session.target" ];

        path = with pkgs; [ dunst ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${lib.getExe pkgs.dunst} -conf ${dunstConfig}";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      # Define services for polybar, udiskie and feh:
      xmonad-polybar = {
        enable = true;
        description = "polybar navigation bar";
        after = [ "xmonad-session.target" ];
        partOf = [ "xmonad-session.target" ];
        wantedBy = [ "xmonad-session.target" ];

        path = with pkgs; [ xmonad-log headsetControl nasToggle rofi-bluetooth rofi ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${lib.getExe pkgs.polybarFull} -config=${./polybar_config.ini} top";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      xmonad-udiskie = {
        enable = true;
        description = "udiskie removable disk automounter";

        after = [ "xmonad-session.target" "xmonad-polybar.service" ];
        partOf = [ "xmonad-session.target" ];
        wantedBy = [ "xmonad-session.target" ];

        path = with pkgs; [ udisks2 libnotify ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${lib.getExe' pkgs.udiskie "udiskie"} --automount --notify --tray";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      xmonad-feh-background = {
        enable = true;
        description = "Set desktop wallpaper";

        after = [ "xmonad-session.target" ];
        partOf = [ "xmonad-session.target" ];
        wantedBy = [ "xmonad-session.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.feh} --no-fehbg --bg-fill ${./wallpaper.jpeg}";
        };
      };

      # Announce airplane mode changes (hardware key, script or nmcli):
      xmonad-rfkill-notify = {
        enable = true;
        description = "airplane mode notifications";
        after = [ "xmonad-session.target" "xmonad-dunst.service" ];
        partOf = [ "xmonad-session.target" ];
        wantedBy = [ "xmonad-session.target" ];

        serviceConfig = {
          Type = "exec";
          ExecStart = lib.getExe rfkillNotify;
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      xmonad-xss-lock = {
        enable = true;
        description = "screen locking service";
        after = [ "xmonad-session.target" ];
        partOf = [ "xmonad-session.target" ];
        wantedBy = [ "xmonad-session.target" ];

        serviceConfig = {
          Type = "exec";
          ExecStartPre = "${lib.getExe pkgs.xset} s 600";
          ExecStart = "${lib.getExe pkgs.xss-lock} --transfer-sleep-lock -- ${lib.getExe pkgs.xlockmore}";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
  };
}
