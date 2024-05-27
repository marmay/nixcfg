{ config, lib, pkgs, ... }:

let userOptions = { name, ... }: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enables the user for the given machine.";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "The user's UID.";
      };
      trusted = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the user is trusted when calling nix.";
      };
      admin = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the user is an administrator.";
      };
      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "cdrom" "video" "render" ];
        description = "Extra groups the user is a member of.";
      };
      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = "The agenix password file.";
      };
    };
  };

  activeUsers = lib.attrsets.filterAttrs (_: value: value.enable) config.marmar.users;

in
{
  options.marmar.users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule userOptions);
    default = {};
    description = "The users to create.";
  };

  config.age.secrets = lib.attrsets.concatMapAttrs (user: userConfig: {
      "userPassword_${user}".file = userConfig.passwordFile;
    }) activeUsers;
  config.users.users = lib.attrsets.mapAttrs (user: userConfig: {
      uid = userConfig.uid;
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets."userPassword_${user}".path;
      extraGroups =
        [ "users" ] ++
        userConfig.extraGroups ++
        (if userConfig.admin then [ "wheel" ] else []);
    }) activeUsers;
  config.home-manager.users = lib.attrsets.mapAttrs (user: userConfig: {
      imports = (import ../users/modules.nix) ++ [ ../../users/${user} ];

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "21.11";
      };
  }) activeUsers;

  config.nix.settings.trusted-users = lib.attrsets.attrNames (lib.attrsets.filterAttrs (_: value: value.trusted) activeUsers);
}

