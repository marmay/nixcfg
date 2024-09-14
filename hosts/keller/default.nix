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
      interfaces.enp5s0 = {
        wakeOnLan.enable = true;
      };
      firewall.allowedTCPPorts = [ 80 443 ];
      extraHosts = ''
        10.0.0.10 webuntis.local
        10.0.0.10 content.webuntis.local
      '';
    };

    virtualisation.docker.enable = true;
    hardware.nvidia-container-toolkit.enable = true;

    hardware.keyboard.qmk.enable = true;
    nix.gc.automatic = false;

    marmar = {
      haskell = true;
      nas_client = true;
      nvidiaGpuSupport = true;
      printingSupport = true;
      scanningSupport = true;
      swaySupport = true;
      steam = true;
      uefi = true;
      xrdp = true;
    };

    marmar.users.markus.enable = true;
    marmar.users.markus.extraGroups = [ "cdrom" "video" "render" ];
    home-manager.users.markus.profiles.agda = true;
    home-manager.users.markus.profiles.dev = true;
    home-manager.users.markus.profiles.xmonad = true;
    home-manager.users.markus.profiles.sway = true;
    home-manager.users.markus.profiles.work = true;
    home-manager.users.markus.profiles.photo = true;

    marmar.users.raphaela.enable = true;
    home-manager.users.raphaela.profiles.school = true;

    virtualisation.waydroid.enable = true;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    environment.etc."sysctl.d/99-for-hogwarts-legacy.conf".text = ''
      vm.max_map_count=1048576
    '';

    #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "555.52.04";
    #  sha256_64bit = "sha256-nVOubb7zKulXhux9AruUTVBQwccFFuYGWrU1ZiakRAI=";
    #  sha256_aarch64 = lib.fakeSha256;
    #  openSha256 = lib.fakeSha256;
    #  settingsSha256 = "sha256-PMh5efbSEq7iqEMBr2+VGQYkBG73TGUh6FuDHZhmwHk=";
    #  persistencedSha256 = lib.fakeSha256;
    #};
  };
}
