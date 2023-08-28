{ config, lib, pkgs, ... }:
{
  options.marmar.swaySupport = lib.mkEnableOption "Sway window manager support";

  config = lib.mkIf config.marmar.swaySupport {
    security.polkit.enable = true;
  };
}
