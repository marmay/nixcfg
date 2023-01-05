{ pkgs, config, ... }:
let commonContainerConfig = import ../common;
in
{
  config.containers.bind = commonContainerConfig.containerNetwork // {
    autoStart = true;
    config = { config, pkgs, ... }: {
      system.stateVersion = "22.05";
      environment.systemPackages = with pkgs; [
        bind
      ];
      environment.etc.bind.source = ./config;
      networking.interfaces.eth0.useDHCP = true;
      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];
      users.users.bind = {
        isSystemUser = true;
        home = "/var/cache/bind";
        createHome = true;
        group = "nogroup";
      };
      systemd.services.named = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        description = "Runs the DNS nameserver from ISC bind9 distribution";
        serviceConfig = {
          Type = "forking";
          ExecStart = "${pkgs.bind}/bin/named -u bind -c /etc/bind/named.conf";
        };
      };
    };
  };
}
