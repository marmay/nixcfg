{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  config = {
    system.stateVersion = "22.11";

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };

    networking = {
      hostName = "notebook";
      networkmanager.enable = true;
    };

    marmar = {
      nas_client = true;
      intelGpuSupport = true;
      printingSupport = true;
      steam = true;
    };

    marmar.users.markus.enable = true;
    marmar.users.marion.enable = true;
    marmar.users.raphaela.enable = true;
    home-manager.users.raphaela.profiles.school = true;
  };
}
