{ config, lib, pkgs, ... }:

let
  kittyTheme = builtins.readFile ./theme.conf;
in
{
  config = {
    programs.kitty = {
      font = {
        name = lib.mkDefault "Fira Code";
        size = lib.mkDefault 9;
      };
      extraConfig = lib.mkDefault kittyTheme;
    };

  } // lib.mkIf config.programs.kitty.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      fira-code
      fira-code-symbols
    ];
  };
}
