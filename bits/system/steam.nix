{ config, lib, pkgs, ... }:
{
  options.marmar.steam = lib.mkEnableOption "Steam";

  config = lib.mkIf config.marmar.steam {
    marmar.sound = true;
    marmar.xserver = true;

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
