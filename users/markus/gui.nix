args@{config, lib, pkgs, ... }:
let user = "markus"; in
{
  imports =
    let withArgs = path: extra: (import path (args // { user = user; } // extra));
    in
  [
    (withArgs ../../bits/users/xsession/xmonad {})
  ] ++ [
    ./smallgui.nix
  ];
}

