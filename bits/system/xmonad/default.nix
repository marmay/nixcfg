{ config, lib, pkgs, nixosConfig, ... }:

let
  cfg = config.marmar.xmonad;
  displaysConfigured = cfg.displays.internal != null && cfg.displays.external != null;

  # Small helpers bound to keys in Config.hs. They carry their own
  # dependencies, so xmonad only needs their paths.
  volumeControl = pkgs.writeShellApplication {
    name = "xmonad-volume";
    runtimeInputs = [ pkgs.wireplumber pkgs.libnotify ];
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
    runtimeInputs = [ pkgs.brightnessctl pkgs.libnotify ];
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
    runtimeInputs = [ pkgs.util-linux ];
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
    runtimeInputs = [ pkgs.util-linux pkgs.libnotify ];
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

        path = with pkgs; [ xmonad-log ];

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
