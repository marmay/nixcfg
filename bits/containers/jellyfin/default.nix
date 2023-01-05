{ lib, pkgs, config, ... }:
let commonContainerConfig = import ../common;
    baseServicePath = commonContainerConfig.path.serviceBase + "/jellyfin";

    servicePaths =
      [ { "host" = "jellyfin/cache"; "container" = "/var/cache/jellyfin"; }
        { "host" = "jellyfin/lib"; "container" = "/var/lib/jellyfin"; }
      ];
in
{
  config = {
    system.activationScripts.makeJellyfinContainerDirs =
      commonContainerConfig.path.mkServicePathActivations
        servicePaths;

    age.secrets = {
      jellyfinVpnCaCert = {
        file = ../../../secrets/markus/vpn/server/buki/cert;
        path = "/run/agenix/jellyfin/ca";
      };
      jellyfinVpnClientCert = {
        file = ../../../secrets/markus/vpn/client/jellyfin/cert;
        path = "/run/agenix/jellyfin/cert";
      };
      jellyfinVpnClientKey = {
        file = ../../../secrets/markus/vpn/client/jellyfin/key;
        path = "/run/agenix/jellyfin/key";
      };
      jellyfinVpnTaKey = {
        file = ../../../secrets/markus/vpn/server/buki/ta.key;
        path = "/run/agenix/jellyfin/ta";
      };
    };

    containers.jellyfin = commonContainerConfig.containerNetwork // {
      autoStart = true;
      enableTun = true;

      bindMounts = {
        "/srv/media/music" = {
          hostPath = commonContainerConfig.path.music;
          isReadOnly = true;
        };
        "/srv/media/videos" = {
          hostPath = commonContainerConfig.path.videos;
          isReadOnly = true;
        };
        "/tmp/.X11-unix".hostPath = "/tmp/.X11-unix";
        "/dev/dri" = {
          hostPath = "/dev/dri";
          isReadOnly = false;
        };
        "/dev/shm" = {
          hostPath = "/dev/shm";
          isReadOnly = false;
        };
        "/run/agenix" = {
          hostPath = "/run/agenix";
          isReadOnly = true;
        };
      } // (lib.lists.foldr lib.attrsets.recursiveUpdate {} (commonContainerConfig.path.mkServicePathBinds servicePaths));

      allowedDevices = [
         {
           node = "/dev/dri";
           modifier = "rw";
         }
         {
           node = "/dev/shm";
           modifier = "rw";
         }
         {
           node = "char-drm";
           modifier = "rwm";
         }
       ];

      config = { config, pkgs, agenix, ... }: {
        imports = [
          ../../system/vpn_client.nix
        ];

        system.stateVersion = "22.05";
        environment.systemPackages = with pkgs; [ libva-utils xterm ];
        hardware.opengl = {
          enable = true;
          driSupport = true;
          extraPackages = with pkgs; [ intel-media-driver vaapiIntel ];
        };
        networking.interfaces.eth0.useDHCP = true;
        services.jellyfin = {
          enable = true;
          openFirewall = true;
        };

        openvpnCfg = {
          enable = true;
          host = "marion-mayr.at";
          serverCert = "/run/agenix/jellyfin/ca";
          clientCert = "/run/agenix/jellyfin/cert";
          clientKey = "/run/agenix/jellyfin/key";
          taKey = "/run/agenix/jellyfin/ta";
        };

        users.users.jellyfin.extraGroups = [ "video" "render" ];
        systemd.tmpfiles.rules = [
          "d /var/lib/jellyfin 700 jellyfin jellyfin -"
          "d /var/cache/jellyfin 700 jellyfin jellyfin -"
        ];
      };
    };

    systemd.nspawn.jellyfin.execConfig.PrivateUsers = false;
  };
}
