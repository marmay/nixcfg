{ config, lib, pkgs, ... }:
let user = "markus"; in
{
  options.marmar.users.${user} = {
    enable = lib.mkEnableOption "Enable ${user}";
    admin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is ${user} an admin?";
    };
    trusted = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is ${user} trusted?";
    };
  };

  config = lib.mkIf config.marmar.users.${user}.enable {
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
        "video"
        "render"
      ] ++ if config.marmar.users.${user}.admin then [ "wheel" ] else []
    };

    nix.settings.trusted-users =
      if config.marmar.users.${user}.trusted then [ "${user}" ] else [];

    home-manager.users.${user} = {
      imports = (import ../../bits/users/modules.nix) ++ [
        ./hm
        ./profiles
      ];

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "21.11";
        packages = with pkgs; [];
      };
    };
  };
}
