# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  options.marmar.sound = lib.mkEnableOption "Sound support";

  config = lib.mkIf config.marmar.sound {
    # hardware.pulseaudio.enable = true;
    # hardware.pulseaudio.systemWide = true;
    hardware.bluetooth.enable = true;
  };
}
