args@{config, lib, pkgs, ... }:
let user = "marion"; in
{
  imports =
  [
    ../../bits/system/gnome.nix
  ];

  config = {
    home-manager.users.${user} = {
      games.settlers3 = true;

      programs = {
        firefox = {
          enable = true;
          profiles.default.settings = {
            "services.sync.username" = "marion.st.mayr@gmail.com";
          };
        };

        thunderbird.enable = true;
      };
      home.packages = with pkgs; [
        calibre
        libreoffice
        qmapshack
      ];
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
  };
}

