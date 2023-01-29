{ config, lib, self, pkgs, ... }:
{
  config = {
    services = {
      avahi = {
        enable = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      printing = {
        enable = true;
        browsing = true;
        browsedConf = ''
          BrowseProtocols none
        '';
        listenAddresses = [ "*:631" ];
        allowFrom = [ "all" ];
        defaultShared = false;
        drivers = with pkgs; [
        ];
        extraConf = builtins.readFile ./printers.conf;
      };
    };
  };
}
