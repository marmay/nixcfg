{ config, lib, self, pkgs, ... }:
{
  config.boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    useOSProber = true;
  };
}
