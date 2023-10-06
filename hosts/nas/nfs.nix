{config, lib, pkgs, ... } :
{
  config = {
    fileSystems."/export/media" = {
      device = "/srv/media";
      options = [ "bind" ];
    };

    fileSystems."/export/recordings" = {
      device = "/srv/recordings";
      options = [ "bind" ];
    };

    networking.firewall.allowedTCPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
    networking.firewall.allowedUDPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];

    services.nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4003;
      exports = ''
        /export               10.0.0.0/24(rw,fsid=0,no_subtree_check,crossmnt)
        /export/media         10.0.0.0/24(rw,no_subtree_check,nohide,insecure)
        /export/recordings    10.0.0.0/24(rw,no_subtree_check)
      '';
    };
  };
}
