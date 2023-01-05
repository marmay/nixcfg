{ config, lib, pkgs, ... }:
{
  config.hardware.opengl = {
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
