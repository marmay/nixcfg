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
    ];
  };
}