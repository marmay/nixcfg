{ config, pkgs, user, ... }:

{
  config.home-manager.users.${user}.services.udiskie = {
    enable = true;
  };
}
