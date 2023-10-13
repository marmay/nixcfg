{ config, lib, pkgs, nixosConfig, ... }:

#assert lib.assertMsg (!config.marmar.xsession.xmonad.enable || nixosConfig.programs.dconf.enable) "dconf is required to enable xmonad";
#assert lib.assertMsg (!config.marmar.xsession.xmonad.enable || nixosConfig.services.dbus.enable) "dbus is required to enable xmonad";
#assert lib.assertMsg (!config.marmar.xsession.xmonad.enable || nixosConfig.services.upower.enable) "upower is required to enable xmonad";

let
  xmobarConfig = builtins.readFile ./xmobar.config;
in
{
  options = {
    marmar.xsession.xmonad = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable xmonad";
      };
    };
  };

  config = lib.mkIf config.marmar.xsession.xmonad.enable {
    home.packages = [
      pkgs.dmenu
      pkgs.feh
    ];

    xdg.configFile."xmobar/.xmobarrc".text = xmobarConfig;
    xsession.enable = true;
    xsession.initExtra = ''
      if test "$(echo $(basename $1) | sed -e 's/[^-]*-\(.*\)/\1/')" != "xsession"; then
        echo "$(basename $1)" > /tmp/xsession.log;
        eval exec "$@";
      fi
      feh --bg-scale ~/.background.jpg &
    '';

    xsession.windowManager.xmonad = {
      enable = true;
      extraPackages = haskellPackages: [ haskellPackages.dbus ];
      enableContribAndExtras = true;
      config = ./config.hs;
    };

    programs.kitty.enable = lib.mkDefault true;
    programs.rofi.enable = lib.mkDefault true;

    services = {
      dunst.enable = lib.mkDefault true;
      # picom.enable = lib.mkDefault true;
      polybar.enable = lib.mkDefault true;
      udiskie.enable = lib.mkDefault true;
    };
  };
}
