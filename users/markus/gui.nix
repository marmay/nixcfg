args@{config, lib, pkgs, ... }:
let user = "markus"; in
{
  imports =
    let withArgs = path: extra: (import path (args // { user = user; } // extra));
    in
  [
    ./smallgui.nix
  ];

  home-manager.users.${user}.marmar.xsession.xmonad.enable = true;
}

