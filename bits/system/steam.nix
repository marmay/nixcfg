# This file will provide a useful steam environment.
{ config, lib, pkgs, ... }:
{
  imports = [
    ./xserver.nix
    ./opengl.nix
    ./sound.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;
    programs.steam.enable = true;
    hardware = {
      pulseaudio.support32Bit = true;
      opengl = {
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          libva
          vaapiVdpau
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          libva
          vaapiVdpau
          libvdpau-va-gl
        ];
        setLdLibraryPath = true;
      };
    };
  };
}
