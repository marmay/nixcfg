{ lib, pkgs, config, ... }:
let commonContainerConfig = import ../common;
    baseServicePath = commonContainerConfig.path.serviceBase + "/tvheadend";

    servicePaths =
      [ { "host" = "tvheadend/lib"; "container" = "/var/lib/tvheadend"; }
      ];
in
{
  config = {
    system.activationScripts.makeJellyfinContainerDirs =
      commonContainerConfig.path.mkServicePathActivations
        servicePaths;
  
    containers.tvheadend = commonContainerConfig.containerNetwork // {
      autoStart = false;
      bindMounts = {
        "/srv/recordings" = {
          hostPath = "/srv/recordings";
          isReadOnly = false;
        };
        "/dev/dvb" = {
          hostPath = "/dev/dvb";
          isReadOnly = false;
        };
      } // (lib.lists.foldr lib.attrsets.recursiveUpdate {} (commonContainerConfig.path.mkServicePathBinds servicePaths));
  
      allowedDevices = [
        { node = "char-DVB";       modifier = "rw"; }
       ];
  
      config = { config, pkgs, ... }: {
        system.stateVersion = "22.05";
        networking.interfaces.eth0.useDHCP = true;
        networking.firewall.allowedTCPPorts = [
          9981 # Web-Interface
          9982 # HTSP
        ];
        # nixpkgs.overlays = [ (import ../../overlays/tvheadend.nix) ];
        services.tvheadend.enable = true;
      };
    };
  };
}
