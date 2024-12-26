# Enables sound and pulseaudio.
{ config, lib, pkgs, ... }:
{
  options.marmar.nvidiaGpuSupport = lib.mkEnableOption "Enable Nvidia GPU support";

  config = lib.mkIf config.marmar.nvidiaGpuSupport {
    hardware.graphics.enable = true;
    hardware.nvidia.modesetting.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
}
