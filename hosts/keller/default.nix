{ config, lib, pkgs, ... }:

{
  imports = [
    ../../bits/system/autoupdate.nix
    ../../bits/system/core.nix
    ../../bits/system/data.nix
    ../../bits/system/gnome.nix
    ../../bits/system/nas_client.nix
    ../../bits/system/nvidia.nix
    ../../bits/system/opengl.nix
    ../../bits/system/pc.nix
    ../../bits/system/printing.nix
    ../../bits/system/scanning.nix
    ../../bits/system/sound.nix
    ../../bits/system/ssh.nix
    ../../bits/system/steam.nix
    ../../bits/system/xserver.nix
    ../../users/markus/core.nix
    ../../users/markus/admin.nix
    ../../users/markus/gui.nix
    ../../users/markus/local.nix
    ../../users/markus/dev.nix
    ./hardware.nix
    ./minecraft.nix
  ];

  config = {
    system.stateVersion = "22.05";

    time.timeZone = "Europe/Vienna";

    networking = {
      hostName = "keller";
      useDHCP = false;
      bridges.br0.interfaces = [ "enp5s0" ];
      interfaces.br0.useDHCP = true;
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
