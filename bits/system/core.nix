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
        sandbox = true;
        trusted-users = [
          "root"
        ];
      };
      extraOptions = ''
        extra-platforms = i686-linux
        experimental-features = nix-command flakes
      '';
    };

    users.mutableUsers = false;
  };
}
