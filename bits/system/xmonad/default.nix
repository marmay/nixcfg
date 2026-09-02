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
      dunst
      feh
      flameshot
      kitty
      lato
      nerd-fonts.iosevka-term
      onboard
      pass
      polybar
      rofi
      udiskie
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

    systemd.user.services = {
      # Only run dunst for the xmonad session:
      xmonad-dunst = {
        enable = true;
        description = "dunst desktop notifications service";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        unitConfig.ConditionEnvironment =
          "XDG_CURRENT_DESKTOP=none+xmonad";
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
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        unitConfig.ConditionEnvironment =
          "XDG_CURRENT_DESKTOP=none+xmonad";
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

        after = [ "graphical-session.target" "polybar.service" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        unitConfig.ConditionEnvironment =
          "XDG_CURRENT_DESKTOP=none+xmonad";
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

        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+xmonad";

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${lib.getExe pkgs.feh} --no-fehbg --bg-fill ${./wallpaper.jpeg}";
        };
      };
    };
  };
}
