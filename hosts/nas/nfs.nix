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
        /export/recordings    10.0.0.10(rw,no_subtree_check)
        /export/media         10.0.0.150(rw,no_subtree_check)
        /export/recordings    10.0.0.150(rw,no_subtree_check)
        /export/media         10.0.0.163(rw,no_subtree_check)
      '';
    };

    # services.samba-wsdd.enable = true;
    # services.samba = {
    #   enable = true;
    #   openFirewall = true;
    #   extraConfig = ''
    #     workgroup = HOME
    #     server string = NAS
    #     netbios name = NAS
    #     security = user
    #     hosts allow = 10.0.0.0/24
    #     hosts deny = 0.0.0.0/0
    #     guest account = nobody
    #     map to guest = bad user
    #   '';
    #   shares = {
    #     Marion = {
    #       path = "/srv/media/Dokumente/Marion";
    #       browseable = "yes";
    #       "read only" = "no";
    #       "guest ok" = "no";
    #       "create mask" = "0644";
    #       "directory mask" = "0755";
    #       "force user" = "marion";
    #       "force group" = "users";
    #     };
    #   };
    # };
  };
}
