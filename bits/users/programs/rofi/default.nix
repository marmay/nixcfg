{ config, lib, pkgs, ... }:

{
  config.programs.rofi = lib.mkIf config.programs.kitty.enable {
    terminal = "${pkgs.kitty}/bin/kitty";
  } // {
    theme = lib.mkDefault ./theme.rafi;
  };
}
