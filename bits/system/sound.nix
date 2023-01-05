# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  config = {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
  };
}
