{ config, lib, pkgs, ... }:
let user = "marion"; in
{
  config = {
    age.secrets = {
      "${user}Password" = {
        file = ../../secrets/markus/users/${user};
      };
    };

    users.users.${user} = {
      uid = 1001;
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

      accounts.email.accounts."marion.st.mayr@gmail.com" = {
        primary = true;
        realName = "Marion Mayr";
        address = "marion.st.mayr@gmail.com";
        flavor = "gmail";
      };

      accounts.email.accounts."marion@marion-mayr.at" =
        (import ../../bits/users/mail/mkBuki.nix ({
          realName = "Marion Mayr";
          address = "marion@marion-mayr.at";
        }));
    };
  };
}
