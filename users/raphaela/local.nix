args@{config, lib, pkgs, ... }:
let user = "raphaela"; in
{
  imports =
    let withArgs = path: extra: (import path (args // { user = user; } // extra));
    in
  [
    (withArgs ../../bits/users/nas_client.nix {})
  ];
}

