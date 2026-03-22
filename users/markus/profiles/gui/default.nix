{ config, lib, pkgs, ... }:
{
  options.profiles.gui = lib.mkEnableOption "Default GUI applications";

  config = lib.mkIf config.profiles.gui {
    programs = {
      firefox.enable = true;
      thunderbird.enable = true;
    };

    home.packages = with pkgs; [
      eog
      tutanota-desktop
    ];

    home.sessionVariables = {
      MOZ_USE_XINPUT2 = 1;
    };
  };
}

