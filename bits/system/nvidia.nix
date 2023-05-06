# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  options.marmar.nvidiaGpuSupport = lib.mkEnableOption "Enable Nvidia GPU support";

  config = lib.mkIf config.marmar.nvidiaGpuSupport {
    hardware.opengl.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
