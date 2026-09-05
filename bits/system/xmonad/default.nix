{ config, lib, pkgs, nixosConfig, ... }:

{
  options = {
    marmar.xmonad = lib.mkEnableOption {
      name = "xmonad";
    };
  };

  config = lib.mkIf config.marmar.xmonad {
    environment.systemPackages = with pkgs; [
      dmenu
      flameshot
      kitty
      lato
      nerd-fonts.iosevka-term
      onboard
      pass
      polybar
      rofi
    ];

    services = {
      xserver = {
        windowManager.xmonad = {
          enable = true;
          extraPackages = haskellPackages: [ haskellPackages.dbus ];
          enableContribAndExtras = true;
          config = ./config.hs;
        };

        xautolock = {
	  enable = true;
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

        after = [ "xmonad-session.target" "polybar.service" ];
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
          RemainAfterExit = true;
          ExecStart = "${lib.getExe pkgs.feh} --no-fehbg --bg-fill ${./wallpaper.jpeg}";
        };
      };
    };
  };
}
