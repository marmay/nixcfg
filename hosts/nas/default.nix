# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
      ./ldap.nix
      ./nfs.nix
      ../../bits/system/core.nix
      ../../bits/system/data.nix
      ../../bits/system/intel.nix
      ../../bits/system/opengl.nix
      ../../bits/system/printing.nix
      ../../bits/system/sound.nix
      ../../bits/system/ssh.nix
      ../../bits/system/steam.nix
      ../../bits/system/xserver.nix
      ../../users/markus/core.nix
      ../../users/markus/admin.nix
      ../../users/markus/gui.nix
      ../../users/markus/local.nix
      ../../users/marion/core.nix
      ../../users/marion/gui.nix
      ../../users/marion/local.nix
      ./hardware.nix
    ] ++ import ./containers.nix;

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.config.allowUnfree = true;
    sharedData.enable = true;
    sharedData.path = "/srv/media";

    time.timeZone = "Europe/Vienna";

    system.stateVersion = "22.11"; # Did you read the comment?

    networking.hostName = "nas"; # Define your hostname.
    networking.useDHCP = false;
    networking.bridges.br0.interfaces = ["enp3s0"];
    networking.interfaces.br0.useDHCP = true;
    networking.networkmanager.enable = false;

    nixpkgs.overlays = import ../../bits/overlays/all.nix;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      firefox
      git
      gnupg
      (pkgs.kodi.passthru.withPackages (kodiPkgs: with kodiPkgs; [
        jellyfin
        joystick
        libretro
        libretro-snes9x
        netflix
        pvr-hts
      ]))
      retroarchFull
      kodi-retroarch-advanced-launchers
      makemkv
      sound-juicer
      vim
      vlc
    ];

    # The NAS never sleeps.
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;
  };
}

