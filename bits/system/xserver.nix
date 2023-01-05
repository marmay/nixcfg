# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  config = {
    services.xserver = {
      enable = true;
      layout = "de";
      libinput.enable = true;
      desktopManager.xterm.enable = true;
    };

    services.openssh.forwardX11 = lib.mkDefault true;
  };
}
