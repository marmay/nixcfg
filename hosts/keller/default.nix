{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./minecraft.nix
  ];

  config = {
    system.stateVersion = "22.05";

    networking = {
      hostName = "keller";
      useDHCP = false;
      bridges.br0.interfaces = [ "enp5s0" ];
      interfaces.br0.useDHCP = true;
    };

    marmar = {
      haskell = true;
      nas_client = true;
      nvidiaGpuSupport = true;
      printingSupport = true;
      scanningSupport = true;
      steam = true;
    };

    marmar.users.markus.enable = true;
    home-manager.users.markus.profiles.dev = true;
    home-manager.users.markus.profiles.xmonad = true;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
