{ config, lib, pkgs, ... }:
{
  config = {
    accounts.email.accounts."markus.mayr@outlook.com" = {
      primary = true;
      realName = "Markus Mayr";
      address = "markus.mayr@outlook.com";
      flavor = "outlook.office365.com";
    } // (import ../../../../bits/util/mail/mailClients.nix { maxAge = 30; });

    accounts.email.accounts."markus@bu-ki.at" =
      (import ../../../../bits/util/mail/mkBuki.nix ({
        realName = "Markus Mayr";
        address = "markus@bu-ki.at";
      }));
  };
}

