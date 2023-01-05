# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  config = {
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
