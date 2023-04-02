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
      imports = (import ../../bits/users/modules.nix);

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
        flavor = "gmail.com";
      } // (import ../../bits/users/mail/mailClients.nix { maxAge = 360; });

      accounts.email.accounts."marion@marion-mayr.at" =
        (import ../../bits/users/mail/mkBuki.nix ({
          realName = "Marion Mayr";
          address = "marion@marion-mayr.at";
        }));
    };
  };
}
