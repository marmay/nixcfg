{ config, pkgs, user, ... }:

{
  config.home-manager.users.${user}.services.dunst = {
    enable = true;
  };
}
