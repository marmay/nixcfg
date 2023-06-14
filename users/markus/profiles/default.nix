{ config, lib, pkgs, ... }:
{
  imports = [ ./dev ./xmonad ./gui ./photo ./work ];
}
