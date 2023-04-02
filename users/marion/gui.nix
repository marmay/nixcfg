args@{config, lib, pkgs, ... }:
let user = "marion"; in
{
  imports =
    let withArgs = path: extra: (import path (args // { user = user; } // extra));
    in
  [
    (withArgs ../../bits/users/programs/firefox.nix {})
    (withArgs ../../bits/users/programs/thunderbird.nix {})
  ] ++ [
    ../../bits/system/gnome.nix
  ];

  config = {
    home-manager.users.${user} = {
      games.settlers3 = true;

      programs = {
        firefox = {
          profiles.default.settings = {
            "services.sync.username" = "marion.st.mayr@gmail.com";
          };
        };
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

