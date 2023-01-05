{ pkgs, config, ... }:
{
  config.services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud24;
    hostName = "cloud.marion-mayr.at";
    https = true;
    
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";

    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";

      adminpassFile = "/var/nextcloud-admin-pass";
      adminuser = "admin";
    };
  };

  config.services.nginx.virtualHosts."cloud.marion-mayr.at".enableACME = true;
  config.services.nginx.virtualHosts."cloud.marion-mayr.at".forceSSL = true;
}
