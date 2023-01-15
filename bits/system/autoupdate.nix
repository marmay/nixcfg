{ config, lib, pkgs, ... }:
{
  config.system.autoUpgrade = {
    enable = true;
    flake = "github:marmay/nixcfg";
    allowReboot = true;
    dates = "daily";
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
  };
}

