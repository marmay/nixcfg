args@{config, lib, pkgs, ... }:
let user = "markus"; in
{
  imports =
    let withArgs = path: extra: (import path (args // { user = user; } // extra));
    in
  [
    (withArgs ../../bits/users/programs/firefox.nix {})
    (withArgs ../../bits/users/programs/thunderbird.nix {})
  ];

  config = {
    home-manager.users.${user} = {
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

