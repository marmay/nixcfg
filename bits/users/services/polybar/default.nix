{ config, pkgs, ... }:

let
  xmonad = ''
    [module/xmonad]
    type = custom/script
    exec = ${pkgs.xmonad-log}/bin/xmonad-log

    tail = true
  '';

  customMods = xmonad;
in
{
  config.fonts.fontconfig.enable = true;
  config.home.packages = with pkgs; [
    font-awesome
    nerdfonts
    material-icons
  ];

  config.services.polybar = {
    package = pkgs.polybarFull;
    config = ./config.ini;
    #extraConfig = bars + colors + mods1 + mods2 + customMods;
    extraConfig = customMods;
    script = ''
      polybar top & disown
    '';
  };
}

