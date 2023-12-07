{ config, lib, pkgs, ... }:
{
  options.profiles.work = lib.mkEnableOption "Work profile";

  config = lib.mkIf config.profiles.work {
    home.packages = with pkgs; [
      remmina
      slack
      teams-for-linux
    ];
  };
}
