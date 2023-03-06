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

      accounts.email.accounts."raphaela@marion-mayr.at" = {
        primary = true;
        address = "raphaela@marion-mayr.at";
        realName = "Raphaela Sophie Mayr";
        userName = "raphaela@marion-mayr.at";
        imap = {
          host = "mail.bu-ki.at";
          port = 143;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        smtp = {
          host = "mail.bu-ki.at";
          port = 587;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };
    };
  };
}
