# This file makes some core settings that are true for
# all nix hosts I maintain.
{ config, lib, pkgs, ... }:
{
  config = {
    i18n.defaultLocale = lib.mkDefault "de_AT.UTF-8";

    console = {
      font = lib.mkDefault "Lat2-Terminus16";
      keyMap = lib.mkDefault "de";
    };

    environment.systemPackages = with pkgs; [
      git
    ];

    networking.firewall.enable = lib.mkDefault true;

    nix = {
      settings = {
        auto-optimise-store = lib.mkDefault true;
        sandbox = lib.mkDefault true;
        trusted-users = [
          "root"
        ];
      };
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        options = lib.mkDefault "--delete-older-than 14d";
      };
      registry.m = {
        from = {
          type = "indirect";
          id = "m";
        };
        to = {
          ref = "master";
          type = "git";
          url = "ssh://git@github.com/marmay/nixcfg";
        };
      };
    };

    time.timeZone = lib.mkDefault "Europe/Vienna";

    users.mutableUsers = false;
  };
}
