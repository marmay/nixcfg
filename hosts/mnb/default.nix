{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  config = {
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
    };

    marmar.users.markus.enable = true;
    # marmar.users.marion.enable = true;
    # marmar.users.raphaela.enable = true;
    # home-manager.users.raphaela.profiles.school = true;
  };
}
