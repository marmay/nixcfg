{ config, lib, self, pkgs, ... }:
{
  options.marmar.uefi = lib.mkEnableOption "UEFI support";

  config.boot.loader = lib.mkIf config.marmar.uefi {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot.enable = true;
    # grub = {
    #   enable = true;
    #   efiSupport = true;
    #   device = "nodev";
    #   useOSProber = true;
    # };
  };
}
