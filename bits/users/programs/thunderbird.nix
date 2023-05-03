{ config, pkgs, user, ... }:
{
  config.programs.thunderbird.profiles.default = {
    isDefault = true;
    settings = {
      "app.donation.eoy.version.viewed" = "1";
      "intl.locale.requested" = "de,en-US";
    };
  };
}

