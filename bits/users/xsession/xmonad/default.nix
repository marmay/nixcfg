args@{ config, lib, pkgs, user, ... }:

let
  xmobarConfig = builtins.readFile ./xmobar.config;
in
{
  imports = let withArgs = p: (import p (args));
    in [
    (withArgs ../../programs/kitty)
    (withArgs ../../programs/rofi)
    (withArgs ../../services/picom)
    (withArgs ../../services/dunst)
    (withArgs ../../services/polybar)
    (withArgs ../../services/udiskie)
  ];

  config = {
    home-manager.users.${user} = { ... } : {
      home.packages = [
        pkgs.haskellPackages.xmobar
        pkgs.dmenu
      ];
      xdg.configFile."xmobar/.xmobarrc".text = xmobarConfig;
      xsession.enable = true;
      xsession.initExtra = ''
        if test "$(basename $1)" != "xterm"; then
          eval exec "$@";
        fi
      '';
      xsession.windowManager.xmonad = {
        enable = true;
        extraPackages = haskellPackages: [ haskellPackages.dbus ];
        enableContribAndExtras = true;
        config = ./config.hs;
      };
    };

    programs.dconf.enable = lib.mkDefault true;

    services = {
      upower.enable = lib.mkDefault true;
      dbus.enable = lib.mkDefault true;
    };
  };
}
