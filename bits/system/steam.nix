{ config, lib, pkgs, ... }:
{
  options.marmar.steam = lib.mkEnableOption "Steam";

  config = lib.mkIf config.marmar.steam {
    marmar.sound = true;
    marmar.xserver = true;

    environment.systemPackages = with pkgs; [
      gamemode
      mangohud
    ];

    nixpkgs.config.allowUnfree = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    programs.steam.gamescopeSession.enable = true;

    boot.extraModprobeConfig = ''
      options bluetooth disable_ertm=1
    '';

    hardware = {
      pulseaudio.support32Bit = true;
      graphics = {
        enable32Bit = true;
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
      };
    };
  };
}
