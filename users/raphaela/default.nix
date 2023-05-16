{config, lib, pkgs, ... }:
{
  config = {
    programs = {
      firefox.enable = true;
      thunderbird.enable = true;
    };

    home.packages = with pkgs; [
      #libreoffice
      gimp
    ];

    accounts.email.accounts."raphaela@marion-mayr.at" =
      (import ../../bits/util/mail/mkBuki.nix {
        realName = "Raphaela Sophie Mayr";
        address = "raphaela@marion-mayr.at";
      }) // { primary = true; };
  };
}
