{ config, lib, pkgs, ... }:
{
  options.profiles.gui = lib.mkEnableOption "Default GUI applications";

  config = lib.mkIf config.profiles.gui {
    programs = {
      firefox.enable = true;
      thunderbird.enable = true;
    };

    home.packages = with pkgs; [
      qmapshack
      gnome.eog
    ];
  };
}

