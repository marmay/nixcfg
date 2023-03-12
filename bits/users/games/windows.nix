{ config, lib, pkgs, user, ... }:
{
  config.home-manager.users."${user}" = {
    home.packages = [
      pkgs.wine
    ];

    xdg.desktopEntries = {
      "Die Siedler 3" = {
        name = "Die Siedler 3";
        exec = "${pkgs.writeShellScript "wine-starter-settlers-3" ''
          export WINEPREFIX="/media/nas/Users/${user}/Spiele/Windows/Siedler3"
          wine "C:\\Settlers 3 Ultimate\\S3.exe"
        ''}";
        terminal = false;
        categories = [ "Game" ];
      };
    };
  };
}
