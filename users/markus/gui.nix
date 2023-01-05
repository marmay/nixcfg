args@{config, lib, pkgs, ... }:
let user = "markus"; in
{
  imports =
    let withArgs = path: extra: (import path (args // { user = user; } // extra));
    in
  [
    (withArgs ../../bits/users/xsession/xmonad {})
  ];

  config = {
    home-manager.users.${user} = {
      programs = {
        firefox.enable = true;
      };
      home.packages = with pkgs; [
      ];
    };
    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
  };
}

