{ config, lib, pkgs, ... }:
{
  options.marmar.intelGpuSupport = lib.mkEnableOption "Intel GPU support";

  config.hardware.opengl = lib.mkIf config.marmar.intelGpuSupport {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
    ];
  };
}
