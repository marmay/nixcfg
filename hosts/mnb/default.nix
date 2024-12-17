{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  config = {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    system.stateVersion = "24.05";

    networking = {
      hostName = "mnb";
      networkmanager.enable = true;
    };

    programs.light.enable = true;
    programs.light.brightnessKeys.enable = true;

    services.fprintd.enable = true;
    services.fprintd.tod.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

    hardware.graphics.extraPackages = with pkgs; [
      vpl-gpu-rt
    ];

    marmar = {
      haskell = true;
      nas_client = true;
      intelGpuSupport = true;
      printingSupport = true;
      steam = true;
      uefi = true;
    };

    marmar.users.markus.enable = true;

    home-manager.users.markus.profiles.dev = true;
    home-manager.users.markus.profiles.xmonad = true;
    home-manager.users.markus.profiles.photo = true;
    home-manager.users.markus.profiles.school = true;
    marmar.users.marion.enable = true;
    marmar.users.raphaela.enable = true;
    marmar.users.gabriel.enable = true;
  };
}
