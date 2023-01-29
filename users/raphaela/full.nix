{ config, lib, pkgs, ... }:
{
  imports = [
    ./core.nix
    ./gui.nix
    ./local.nix
  ];
}
