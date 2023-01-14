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

    home-manager.users.${user}.home = {
      username = "${user}";
      homeDirectory = "/home/${user}";
      stateVersion = "21.11";
      packages = with pkgs; [];
    };
  };
}
