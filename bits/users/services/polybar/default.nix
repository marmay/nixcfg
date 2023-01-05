{ config, pkgs, user, ... }:

let
  mypolybar = pkgs.polybar.override {
    alsaSupport   = true;
    pulseSupport  = true;
  };

  # theme adapted from: https://github.com/adi1090x/polybar-themes#-polybar-5
  bars   = builtins.readFile ./bars.ini;
  colors = builtins.readFile ./colors.ini;
  mods1  = builtins.readFile ./modules.ini;
  mods2  = builtins.readFile ./user_modules.ini;

  monitorScript   = pkgs.callPackage ./scripts/monitor.nix {};
  networkScript   = pkgs.callPackage ./scripts/network.nix {};

  cal = ''
    [module/clickable-date]
    inherit = module/date
  '';

  xmonad = ''
    [module/xmonad]
    type = custom/script
    exec = ${pkgs.xmonad-log}/bin/xmonad-log

    tail = true
  '';

  customMods = cal + xmonad;
in
{
  config.home-manager.users.${user}.services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./config.ini;
    extraConfig = bars + colors + mods1 + mods2 + customMods;
    script = ''
      polybar top & disown
    '';
  };
}

