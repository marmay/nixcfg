# This file makes some core settings that are true for
# all nix hosts I maintain.
{ config, lib, pkgs, ... }:
{
  config = {
    i18n.defaultLocale = "de_AT.UTF-8";

    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };

    environment.systemPackages = with pkgs; [
      git
    ];

    networking.firewall.enable = lib.mkDefault true;

    nix = {
      settings = {
        auto-optimise-store = true;
        sandbox = true;
        trusted-users = [
          "root"
        ];
      };
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
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

    users.mutableUsers = false;
  };
}
