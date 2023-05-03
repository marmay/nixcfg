{ config, pkgs, ... }:
{
  config.services.picom = {
    activeOpacity = 1.0;
    inactiveOpacity = 0.8;
    backend = "glx";
    vSync = true;
    fade = true;
    fadeDelta = 5;
    opacityRules = [ "100:name *= 'i3lock'" ];
    shadow = true;
    shadowOpacity = 0.75;
  };
}
