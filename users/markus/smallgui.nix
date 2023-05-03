args@{config, lib, pkgs, ... }:
let user = "markus"; in
{
  config = {
    home-manager.users.${user} = {
      programs = {
        firefox.enable = true;
        thunderbird.enable = true;
      };

      home.packages = with pkgs; [
        qmapshack
        gnome.eog
      ];
    };
    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
  };
}

