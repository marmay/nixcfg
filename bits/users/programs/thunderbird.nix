{ config, pkgs, user, ... }:
{
  config.home-manager.users."${user}".programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "app.donation.eoy.version.viewed" = "1";
        "intl.locale.requested" = "de,en-US";
      };
    };
  };
}

