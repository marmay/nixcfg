# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  options.marmar.xserver = lib.mkEnableOption "X server";
  options.marmar.xrdp = lib.mkEnableOption "XRDP";

  config = lib.mkIf config.marmar.xserver {
    xdg.portal.enable = lib.mkForce false;

    services.xserver = {
      enable = true;
      xkb.layout = "de";
      xkb.variant = "nodeadkeys";
      desktopManager.xterm.enable = true;
      updateDbusEnvironment = true;
    };

    services.libinput = {
      enable = true;
    };

    services.openssh.settings.X11Forwarding = lib.mkDefault true;

    services.xrdp = lib.mkIf config.marmar.xrdp {
      enable = true;
      openFirewall = true;
      defaultWindowManager = "xsession";
    };
  };
}
