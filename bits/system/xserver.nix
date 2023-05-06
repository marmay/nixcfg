# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  options.marmar.xserver = lib.mkEnableOption "X server";

  config = lib.mkIf config.marmar.xserver {
    services.xserver = {
      enable = true;
      layout = "de";
      libinput.enable = true;
      desktopManager.xterm.enable = true;
    };

    services.openssh.forwardX11 = lib.mkDefault true;
  };
}
