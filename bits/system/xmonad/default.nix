{ config, lib, pkgs, nixosConfig, ... }:

{
  options = {
    marmar.xmonad = lib.mkEnableOption {
      name = "xmonad";
    };
  };

  config = lib.mkIf config.marmar.xmonad {
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
          ExecStart = "${lib.getExe pkgs.dunst}";
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
