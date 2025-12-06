{ config, lib, pkgs, ... }:
{
  options.marmar.intelGpuSupport = lib.mkEnableOption "Intel GPU support";

  config.hardware.graphics = lib.mkIf config.marmar.intelGpuSupport {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
    ];
  };
}
