{ config, lib, pkgs, ... }:

{
  imports = [
    ../../bits/system/autoupdate.nix
    ../../bits/system/core.nix
    ../../bits/system/data.nix
    ../../bits/system/gnome.nix
    ../../bits/system/nas_client.nix
    ../../bits/system/opengl.nix
    ../../bits/system/printing.nix
    ../../bits/system/rpi.nix
    ../../bits/system/sound.nix
    ../../bits/system/spotifyd.nix
    ../../bits/system/ssh.nix
    ../../bits/system/xserver.nix
    ../../users/markus/core.nix
    ../../users/markus/admin.nix
    ../../users/raphaela/full.nix
  ];

  config = {
    system.stateVersion = "22.11";

    marmar = {
      nas_client = true;
      printingSupport = true;
      rpi = true;
    };

    marmar.users.markus.enable = true;
    marmar.users.raphaela.enable = true;

    networking = {
      hostName = "raphberry";
      networkmanager.enable = true;
    };

    services.spotifyd.enable = true;
  };
}

