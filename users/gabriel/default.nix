{config, lib, pkgs, ... }:
{
  imports = [ ./profiles ];

  config = {
    programs = {
      firefox.enable = true;
      thunderbird.enable = true;
    };

    home.packages = with pkgs; [
      libreoffice
      bsdgames
    ];

    accounts.email.accounts."gabriel@marion-mayr.at" =
      (import ../../bits/util/mail/mkBuki.nix {
        realName = "Gabriel Mayr";
        address = "gabriel@marion-mayr.at";
      }) // { primary = true; };
  };
}

