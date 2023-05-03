args@{config, lib, pkgs, ... }:
let user = "raphaela"; in
{
  imports =
  [
    ../../bits/system/gnome.nix
  ];

  config = {
    home-manager.users.${user} = {
      programs = {
        firefox.enable = true;
        thunderbird.enable = true;
      };

      home.packages = with pkgs; [
        libreoffice
        gimp
      ];
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
  };
}
