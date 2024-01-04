# The main purpose of this file is to import any user-specific modules.
{ config, lib, pkgs, ... }:
{
  imports = [
    ./latex
    ./mail
    ./programs/neovim
    ./programs/emacs
  ];
}

