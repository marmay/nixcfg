args@{config, lib, pkgs, ... }:
let user = "raphaela"; in
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
