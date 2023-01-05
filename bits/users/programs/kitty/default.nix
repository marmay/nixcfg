{ config, pkgs, user, ... }:

let
  kittyTheme = builtins.readFile ./theme.conf;
in
{
  config = {
    fonts.fonts = with pkgs; [
      fira-code
      fira-code-symbols
    ];

    home-manager.users."${user}" = { ... } : {
      programs.kitty = {
        enable = true;
        font = {
          name = "Fira Code";
          size = 9;
        };
        extraConfig = kittyTheme;
      };
    };
  };
}
