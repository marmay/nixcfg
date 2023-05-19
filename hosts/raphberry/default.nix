{ config, lib, pkgs, ... }:

{
  imports = [
  ];

  config = {
    system.stateVersion = "22.11";

    marmar = {
      nas_client = true;
      # printingSupport = true;
      rpi = true;
      vc4-kms = true;
    };

    marmar.users.markus.enable = true;
    marmar.users.raphaela.enable = true;

    networking = {
      hostName = "raphberry";
      networkmanager.enable = true;
    };

    # services.spotifyd.enable = true;
  };
}

