{ config, lib, pkgs, ... }:
{
  config.system.autoUpgrade = {
    enable = true;
    flake = "ssh+git://git@github.com/marmay/nixcfg";
    allowReboot = true;
    dates = "daily";
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
  };
}

