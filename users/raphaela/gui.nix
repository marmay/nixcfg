args@{config, lib, pkgs, ... }:
let user = "marion"; in
{
  imports = [
    ../../bits/system/gnome.nix
  ];

  config = {
    home-manager.users.${user} = {
      programs = {
        firefox = {
          enable = true;
          profiles.default.settings = {
            "media.gmp-widevinecdm.enabled" = "true";
            "intl.accept_languages" = "de_AT,de,en_US,en";
            "intl.locale.requested" = "de,en-US";
          };
        };
      };
      home.packages = with pkgs; [
      ];
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
  };
}

