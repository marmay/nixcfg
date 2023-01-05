{ pkgs, config, ... }:
{
  config.services.postgresql = {
    enable = true;
    ensureDatabases = [ "kindergartenbuecherei" ];
    ensureUsers = [
      {
        "name" = "buki";
        ensurePermissions = {
          "DATABASE kindergartenbuecherei" = "ALL PRIVILEGES";
        };
      }
    ];
    initialScript = pkgs.writeText "Initial-PostgreSQL-Setup" ''
      create extension if not exists "uuid-ossp";
    '';
  };
}
