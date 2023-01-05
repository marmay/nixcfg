
# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  config = {
    hardware.opengl.enable = true;
  };
}
