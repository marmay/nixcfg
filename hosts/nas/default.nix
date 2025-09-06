# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware.nix
      ./ldap.nix
      ./nfs.nix
    ] ++ import ./containers.nix;

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    marmar = {
      nas_client = true;
      intelGpuSupport = true;
      printingSupport = true;
      steam = true;
    };

    marmar.users.markus.enable = true;
    marmar.users.marion.enable = true;
    marmar.users.raphaela.enable = true;

    system.stateVersion = "22.11"; # Did you read the comment?

    networking.hostName = "nas"; # Define your hostname.
    networking.useDHCP = false;
    networking.bridges.br0.interfaces = ["enp3s0"];
    networking.interfaces.br0.useDHCP = true;
    networking.networkmanager.enable = false;

    age.secretsDir = "/run/agenix.d/current";

    nixpkgs.overlays = import ../../bits/overlays/all.nix;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      (pkgs.kodi.passthru.withPackages (kodiPkgs: with kodiPkgs; [
        jellyfin
        joystick
        netflix
        pvr-hts
      ]))
    ];

    # The NAS never sleeps.
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    # One of the backup strategies is to take snapshots of the data volume
    # under /mnt/old_root:
    services.snapper.configs."/mnt/old_root" = {
      SUBVOLUME = "/mnt/old_root";
      FSTYPE = "btrfs";
      TIMELINE_CREATE=true;
      TIMELINE_CLEANUP=true;
      TIMELINE_LIMIT_HOURLY=24;
      TIMELINE_LIMIT_DAILY=30;
      TIMELINE_LIMIT_MONTHLY=12;
      TIMELINE_LIMIT_YEARLY=0;
    };
  };
}

