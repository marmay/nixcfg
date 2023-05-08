{ config, lib, pkgs, ... }:
{
  options.profiles.dev = lib.mkEnableOption "Development tasks";

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
  };
}
