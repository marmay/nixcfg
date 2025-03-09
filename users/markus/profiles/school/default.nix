{ config, lib, pkgs, ... }:
{
  options.profiles.school = lib.mkEnableOption "School profile";

  config = lib.mkIf config.profiles.school {
    home.packages = with pkgs; [

      # Schule
      anki
      ocamlPackages.cpdf
      onedrive
      gnumake
      geogebra6
      davinci-resolve
      inkscape
      gimp
      teams-for-linux
      libreoffice
      xournalpp
    ];
  };
}
