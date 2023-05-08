{ config, lib, pkgs, ... }:
{
  options.profiles.xmonad = lib.mkEnableOption "My XMonad session";

  config = lib.mkIf config.profiles.xmonad {
    profiles.gui = true;
    marmar.xsession.xmonad.enable = true;
  };
}
