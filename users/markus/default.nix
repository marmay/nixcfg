{ config, lib, pkgs, ... }:
let
  aspell = pkgs.aspellWithDicts (ps: with ps; [
	  de
	]);
in
{
  imports = [ ./hm ./profiles ];
  config = {
    home.file.".background.jpg".source = ./background.jpg;
    home.packages = [
      aspell
    ];
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gtk2;
    };
  };
}
