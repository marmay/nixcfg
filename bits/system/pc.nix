{ config, lib, self, pkgs, ... }:
{
  options.marmar.uefi = lib.mkEnableOption "UEFI support";

  config.boot.loader.grub = lib.mkIf config.marmar.uefi {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    useOSProber = true;
  };
}
