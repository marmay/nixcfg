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
    nerdfonts
    lato
  ];

  config.services.polybar = {
    package = pkgs.polybarFull;
    config = ./config.ini;
    extraConfig = customMods;
    script = ''
      polybar top & disown
    '';
  };
}

