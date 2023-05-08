{ config, lib, pkgs, ... }:
{
  options.marmar.gnome = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable the GNOME desktop environment.";
  };

  config = lib.mkIf config.marmar.gnome {
    marmar.xserver = true;
    marmar.sound = true;

    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}

