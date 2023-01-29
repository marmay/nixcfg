{config, lib, pkgs, ... }:
let user = "markus"; in
{
  config = {
    home-manager.users.${user} = {
      programs = {
        firefox.enable = true;
      };
      home.packages = with pkgs; [
        qmapshack
      ];
    };
    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
  };
}

