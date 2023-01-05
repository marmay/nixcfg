{ config, pkgs, ... }:
{
  config.services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;

    virtualHosts."bu-ki.at" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8000";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
          ;
      };
    };

    virtualHosts."media.marion-mayr.at" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.8.0.10:8096";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
          ;
      };
    };

    virtualHosts."marion-mayr.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = ./sites/marion-mayr.at;
        extraConfig = ''
          default_type text/html;
        '';
      };
    };
  };
}
