{ config, pkgs, user, ... }:

{
  config.home-manager.users."${user}" = { ... } : {
    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "curses";
    };
  };
}
