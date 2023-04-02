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
      2049 # For NFS
    ];

    services.nfs.server = {
      enable = true;
      exports = ''
        /export/media         10.0.0.10(rw,no_subtree_check)
        /export/media         10.0.0.80(rw,no_subtree_check)
        /export/media         10.0.0.150(rw,no_subtree_check)
        /export/media         10.0.0.163(rw,no_subtree_check)
        /export/recordings    10.0.0.10(rw,no_subtree_check)
        /export/recordings    10.0.0.150(rw,no_subtree_check)
      '';
    };
  };
}
