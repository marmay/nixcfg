{ config, lib, pkgs, ... }:
{
  options.profiles.photo = lib.mkEnableOption "Profile for downloading and editing photos";

  config = lib.mkIf config.profiles.photo {
    home.packages = with pkgs; [
      rapid-photo-downloader
      darktable
    ];
  };
}