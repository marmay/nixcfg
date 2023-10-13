{ config, lib, pkgs, ... }:
{
  imports = [ ./hm ./profiles ];
  config = {
    home.file.".background.jpg".source = ./background.jpg;
  };
}
