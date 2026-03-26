{ config, lib, pkgs, ... }:
{
  options.marmar.steam = lib.mkEnableOption "Steam";

  config = lib.mkIf config.marmar.steam {
    marmar.sound = true;
    marmar.xserver = true;

    environment.systemPackages = with pkgs; [
      dosbox
      gamemode
      mangohud
      lutris
      prismlauncher
    ];

    nixpkgs.config.allowUnfree = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
