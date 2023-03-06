args@{config, lib, pkgs, ... }:
let user = "raphaela"; in
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
        thunderbird = {
          enable = true;
          profiles.default = {
            isDefault = true;
            settings = {
              "app.donation.eoy.version.viewed" = "1";
              "intl.locale.requested" = "de,en-US";
            };
          };
        };
      };
      home.packages = with pkgs; [
        libreoffice
        gimp
      ];
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
  };
}
