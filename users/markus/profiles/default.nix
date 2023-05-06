{ config, lib, pkgs, ... }:
{
  options.profiles.dev = lib.mkEnableOption "Development tasks";
  options.profiles.xmonad = lib.mkEnableOption "My XMonad session";
  options.profiles.gui = lib.mkEnableOption "Default GUI applications";

  config = lib.mkIf config.profiles.dev {
    programs = {
      fish.enable = true;
      htop.enable = true;
      emacs.enable = true;
      neovim.enable = true;
      git = {
        enable = true;
        userName = "Markus Mayr";
        userEmail = "markus.mayr@outlook.com";
      };
    };
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  } // lib.mkIf config.profiles.xmonad {
    profiles.gui = true;
    marmar.xsession.xmonad.enable = true;
  } // lib.mkIf config.profiles.gui {
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
