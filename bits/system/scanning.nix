# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  config = {
    hardware.sane.enable = true;
  };
}

