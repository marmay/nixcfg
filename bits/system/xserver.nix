# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  options.marmar.xserver = lib.mkEnableOption "X server";

  config = lib.mkIf config.marmar.xserver {
    xdg.portal.enable = lib.mkForce false;

    services.xserver = {
      enable = true;
      layout = "de";
      libinput.enable = true;
      desktopManager.xterm.enable = true;
      updateDbusEnvironment = true;
    };

    services.openssh.settings.X11Forwarding = lib.mkDefault true;
  };
}
