{ config, lib, pkgs, ... }:

{
  config.home-manager.users.${user} = { ... } : {
    programs.steam = {
      enable = true;
    };
  };
}
