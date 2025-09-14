{ config, lib, pkgs, ... }:
{
  options.profiles.print3d = lib.mkEnableOption "3d Printing Profile";

  config = lib.mkIf config.profiles.school {
    home.packages = with pkgs; [
      cura-appimage
    ];
  };
}
