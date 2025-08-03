
{ config, lib, pkgs, ... }:
{
  options.profiles.school = lib.mkEnableOption "School profile";

  config = lib.mkIf config.profiles.school {
    home.packages = with pkgs; [
      anki
      teams-for-linux
      libreoffice
      scribus
      gimp
      inkscape
    ];
    programs.emacs.enable = true;
  };
}
