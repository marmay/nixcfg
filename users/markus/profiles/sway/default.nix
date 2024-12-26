{ config, lib, pkgs, ... }:
{
  options.profiles.sway = lib.mkEnableOption "My Sway session";

  config = lib.mkIf config.profiles.sway {
    wayland.windowManager.sway = {
      enable = true;
      extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1;
      '';
      config = rec {
        modifier = "Mod4";
        # Use kitty as default terminal
        terminal = "kitty";
        input = {
          "*" = {
            xkb_layout = "de";
          };
        };
        startup = [
          # Launch Firefox on start
          {command = "firefox";}
        ];
      };
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };

    programs.kitty.enable = lib.mkDefault true;
    programs.firefox.enable = lib.mkDefault true;
    programs.thunderbird.enable = lib.mkDefault true;
  };
}
