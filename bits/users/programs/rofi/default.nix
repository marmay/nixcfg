{ pkgs, config, user, ... }:

{
  config.home-manager.users.${user} = { ... } : {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.kitty}/bin/kitty";
      # theme = ./theme.rafi;
    };
  };
}
