{ config, lib, pkgs, ... }:

{
  imports = [
    ../../bits/system/core.nix
    ../../bits/system/data.nix
    ../../bits/system/gnome.nix
    ../../bits/system/intel.nix
    ../../bits/system/nas_client.nix
    ../../bits/system/opengl.nix
    ../../bits/system/printing.nix
    ../../bits/system/sound.nix
    ../../bits/system/ssh.nix
    ../../bits/system/steam.nix
    ../../bits/system/xserver.nix
    ../../users/markus/core.nix
    ../../users/markus/admin.nix
    ../../users/markus/local.nix
    ../../users/marion/core.nix
    ../../users/marion/gui.nix
    ../../users/marion/local.nix
    ./hardware.nix
  ];

  config = {
    system.stateVersion = "22.11";

    time.timeZone = "Europe/Vienna";

    boot.loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
      useOSProber = true;
    };

    networking = {
      hostName = "notebook";
      wireless.enable = true;
      networkmanager.enable = false;
    };

    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
