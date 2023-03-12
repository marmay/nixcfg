{ config, lib, pkgs, ... }:
let user = "raphaela"; in
{
  config = {
    age.secrets = {
      "${user}Password" = {
        file = ../../secrets/markus/users/${user};
      };
    };

    users.users.${user} = {
      uid = 1002;
      isNormalUser = true;
      passwordFile = config.age.secrets."${user}Password".path;
      extraGroups = [
        "users"
        "cdrom"
      ];
    };

    home-manager.users.${user} = {
      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "21.11";
        packages = with pkgs; [];
      };

      accounts.email.accounts."raphaela@marion-mayr.at" =
        (import ../../bits/users/mail/mkBuki.nix {
          realName = "Raphaela Sophie Mayr";
          address = "raphaela@marion-mayr.at";
        }) // { primary = true; };
    };
  };
}
