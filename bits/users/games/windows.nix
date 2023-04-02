{ config, lib, pkgs, ... }:
{
  options = {
    games.settlers3 = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to create a starter for the game settlers 3.";
      default = false;
    };
  };

  config = lib.mkIf config.games.settlers3 {
    home.packages = [ pkgs.wine ];
    xdg.desktopEntries = {
      "Die Siedler 3" = {
        name = "Die Siedler 3";
        exec = "${pkgs.writeShellScript "wine-starter-settlers-3" ''
          export WINEPREFIX="/media/nas/Users/${config.home.username}/Spiele/Windows/Siedler3"
          cd "$WINEPREFIX/drive_c/Settlers 3 Ultimate"
          taskset -c 0 wine ./S3.exe
        ''}";
        terminal = false;
        categories = [ "Game" ];
      };
    };
  };
}
