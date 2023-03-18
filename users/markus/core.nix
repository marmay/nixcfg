{ config, lib, pkgs, ... }:
let user = "markus"; in
{
  config = {
    age.secrets = {
      "${user}Password" = {
        file = ../../secrets/markus/users/${user};
      };
    };

    users.users.${user} = {
      uid = 1000;
      isNormalUser = true;
      passwordFile = config.age.secrets."${user}Password".path;
      extraGroups = [
        "users"
        "cdrom"
      ];
    };

    home-manager.users.${user} = {
      imports = (import ../../bits/users/modules.nix);

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "21.11";
        packages = with pkgs; [];
      };

      accounts.email.accounts."markus.mayr@outlook.com" = {
        primary = true;
        realName = "Markus Mayr";
        address = "markus.mayr@outlook.com";
        flavor = "outlook.office365.com";
      } // (import ../../bits/users/mail/mailClients.nix { maxAge = 30; });

      accounts.email.accounts."markus@bu-ki.at" =
        (import ../../bits/users/mail/mkBuki.nix ({
          realName = "Markus Mayr";
          address = "markus@bu-ki.at";
        }));
    };
  };
}
