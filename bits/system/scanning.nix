# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  options.marmar.scanningSupport = lib.mkEnableOption "Scanner support";

  config = lib.mkIf config.marmar.scanningSupport {
    hardware.sane.enable = true;
  };
}

