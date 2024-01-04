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
    };

    hardware.keyboard.qmk.enable = true;

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
  };
}
