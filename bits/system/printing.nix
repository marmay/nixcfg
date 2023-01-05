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
        listenAddresses = [ "*:631" ];
        allowFrom = [ "all" ];
        defaultShared = false;
        drivers = with pkgs; [
        ];
      };
    };
  };
}
