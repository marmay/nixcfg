{ config, lib, pkgs, ... }:
{
  imports = [ ./agda ./dev ./xmonad ./gui ./photo ./sway ./work ];
}
