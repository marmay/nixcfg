{ config, lib, pkgs, ... }:
{
  config = {
    programs = {
      firefox.enable = true;
      thunderbird.enable = true;
    };

    home.packages = with pkgs; [
      qmapshack
      gnome.eog
    ];

    accounts.email.accounts = {
      "marion.st.mayr@gmail.com" = {
        primary = true;
        realName = "Marion Mayr";
        address = "marion.st.mayr@gmail.com";
        flavor = "gmail.com";
      } // (import ../../bits/users/mail/mailClients.nix { maxAge = 360; });

      "marion@marion-mayr.at" =
        (import ../../bits/users/mail/mkBuki.nix ({
          realName = "Marion Mayr";
          address = "marion@marion-mayr.at";
        }));
    };
  };
}
