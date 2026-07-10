{ config, lib, pkgs, ... }:
{
  config.programs.firefox = {
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.default.settings = {
      "media.gmp-widevinecdm.enabled" = "true";
      "intl.accept_languages" = "de_AT,de,en_US,en";
      "intl.locale.requested" = "de,en-US";
    };
  };
}
