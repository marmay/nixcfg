{ config, lib, pkgs, ... }:
let keys = import ../../secrets/keys.nix;
in
{
  config = {
    services.openssh = {
      enable = true;
      knownHosts = {
        "github.com/rsa" = {
          hostNames = [ "github.com" ];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
        };
        "github.com/ed25519" = {
          hostNames = [ "github.com" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
        "github.com/ecdsa" = {
          hostNames = [ "github.com" ];
          publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
        };
        "nas" = {
          hostNames = [ "nas" "nas.local" "nas.home" "10.0.0.80" ];
          publicKey = keys.nas;
        };
        "keller" = {
          hostNames = [ "keller" "keller.local" "keller.home" "10.0.0.10" ];
          publicKey = keys.keller;
        };
        "notebook" = {
          hostNames = [ "notebook" "notebook.local" "notebook.home" "10.0.0.150" ];
          publicKey = keys.notebook;
        };
        "raphberry" = {
          hostNames = [ "raphberry" "raphberry.local" "raphberry.home" "10.0.0.163" ];
          publicKey = keys.raphberry;
        };
        #"bu-ki.at" = {
        #  hostNames = [ "bu-ki.at" ];
        #  publickey = keys.buki;
        #};
      };
    };
  };
}
