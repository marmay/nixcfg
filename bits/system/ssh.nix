# Enables scanner support.
{ config, lib, pkgs, ... }:
{
  config = {
    services.openssh = {
      enable = true;
    };
  };
}
