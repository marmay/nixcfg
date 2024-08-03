{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  config = {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    system.stateVersion = "24.05";

    networking = {
      hostName = "mnb";
      networkmanager.enable = true;
    };

    marmar = {
      nas_client = true;
      intelGpuSupport = true;
      printingSupport = true;
      steam = true;
      uefi = true;
    };

    marmar.users.markus.enable = true;

    home-manager.users.markus.profiles.dev = true;
    home-manager.users.markus.profiles.xmonad = true;
    home-manager.users.markus.profiles.sway = true;
    # marmar.users.marion.enable = true;
    # marmar.users.raphaela.enable = true;
    # home-manager.users.raphaela.profiles.school = true;
    marmar.users.gabriel.enable = true;
  };
}
