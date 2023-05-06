{ config, lib, pkgs, ... }:
{
  options.marmar.autoUpgrade = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Automatically upgrade packages";
  };

  config.system.autoUpgrade = lib.mkIf config.marmar.autoUpgrade {
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

