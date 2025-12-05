{ config, lib, pkgs, ... }:
{
  options.profiles.school = lib.mkEnableOption "School profile";

  config = lib.mkIf config.profiles.school {
    profiles.latex = true;
    
    home.packages = with pkgs; [
      # Schule
      anki
      gnumake
      # geogebra6
      gimp
      inkscape
      libreoffice
      ocamlPackages.cpdf
      onedrive
      pandoc
      pdf2svg
      teams-for-linux
      xournalpp
    ];
  };
}
