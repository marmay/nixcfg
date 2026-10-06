{ config, lib, pkgs, ... }:

let
  cfg = config.marmar.nas_client;
  server = "10.0.0.80";
  nfsUnit = "media-nas.mount";

  # Two modes. Automatic: every mount is behind an automount and comes up on
  # first access (fine for machines that are always on the network). Manual:
  # nothing touches the network until nas.target is started, e.g. through the
  # NAS switch in xmonad; off-network the directories are plain local ones.
  automountOpts = [ "x-systemd.automount" "x-systemd.device-timeout=10s" "noauto" ];

  nfsOpts =
    # Pin NFSv4: without it mount.nfs silently falls back to v3 (lockd, statd,
    # mountd) whenever the v4 path lookup fails. Requires the server to export
    # the shares in its v4 pseudo root under their real paths (no fsid=0).
    [ "vers=4.2" ]
    ++ (if cfg.manual then [
      "noauto" "nofail" "_netdev"
      # Fail fast when the server is unreachable instead of hanging:
      "soft" "timeo=100" "retrans=3" "retry=0" "x-systemd.mount-timeout=20s"
      "x-systemd.required-by=nas.target"
    ] else automountOpts);

  linkOpts =
    [ "bind" "_netdev" "comment=x-gvfs-hide" ]
    ++ (if cfg.manual then [
      "noauto" "nofail"
      "x-systemd.requires=${nfsUnit}" "x-systemd.after=${nfsUnit}"
      "x-systemd.required-by=nas.target"
    ] else automountOpts);

  mkLink = target: source: lib.nameValuePair target { device = source; fsType = "auto"; options = linkOpts; };
  mkUserLink = user: n: mkLink "/home/${user}/${n}" "${config.sharedData.path}/Users/${user}/${n}";
  mkSharedLink = user: n: mkLink "/home/${user}/Gemeinsam/${n}" "${config.sharedData.path}/${n}";
  mkLinks = user: [
      (mkUserLink user "Bilder")
      (mkUserLink user "Downloads")
      (mkUserLink user "Dokumente")
      (mkUserLink user "Schreibtisch")
      (mkUserLink user "Videos")
      (mkUserLink user "Vorlagen")
      (mkSharedLink user "Bilder")
      (mkSharedLink user "Dokumente")
      (mkSharedLink user "E-Books")
      (mkSharedLink user "Musik")
      (mkSharedLink user "Spiele")
      (mkSharedLink user "Videos")
    ];
  users = lib.attrsets.attrNames (lib.attrsets.filterAttrs (_: v: v.enable) config.marmar.users);
in

{
  options.marmar.nas_client = {
    enable = lib.mkEnableOption "mounting the NAS shares";

    manual = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Mount only on request (nas.target) instead of on first access. For
        machines that are frequently away from the NAS; the users may start
        and stop the mounts without a password.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems =
      {
        "/media/nas" = {
          device = "${server}:/export/media";
          fsType = "nfs";
          options = nfsOpts;
        };
      }
      // builtins.listToAttrs (lib.lists.concatMap mkLinks users);

    # Manual mode: one target that pulls in every mount, a real unmount, and
    # permission for the users to switch.
    systemd.targets.nas = lib.mkIf cfg.manual {
      description = "NAS shares mounted";
    };

    # ForceUnmount aborts outstanding requests when the server is gone. No
    # LazyUnmount on purpose: a lazy unmount only hides the mount point while
    # the NFS superblock lives on behind every open file, working directory
    # or inotify watch (Firefox in ~/Downloads, Emacs in ~/Dokumente). The
    # kernel then keeps talking to an unreachable server, and such a ghost
    # mount has frozen this notebook around suspend more than once. A busy
    # mount now fails to unmount instead, and the NAS switch names the
    # processes holding it.
    systemd.units."${nfsUnit}" = lib.mkIf cfg.manual {
      overrideStrategy = "asDropin";
      text = ''
        [Mount]
        ForceUnmount=yes
      '';
    };

    # Never carry an NFS mount through a suspend: detach before sleeping and
    # reattach after resume once the server answers again. Only a mount that
    # was active at bedtime is restored; an explicit disconnect stays
    # disconnected.
    systemd.services.nas-sleep = lib.mkIf cfg.manual {
      description = "Detach the NAS shares around system sleep";
      before = [ "sleep.target" ];
      wantedBy = [ "sleep.target" ];
      unitConfig.StopWhenUnneeded = true;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStopSec = 30;
      };
      path = [ pkgs.systemd pkgs.coreutils pkgs.util-linux pkgs.gnugrep pkgs.bash ];
      script = ''
        marker=/run/nas-sleep.remount
        rm -f "$marker"
        if systemctl is-active --quiet ${nfsUnit}; then
          touch "$marker"
          systemctl stop ${nfsUnit} || true
        fi
        # Bind mounts whose unmount failed (busy) are tried once more; what
        # remains is logged, it keeps the NFS superblock alive through sleep.
        for t in $(findmnt -rn -t nfs,nfs4 -o TARGET || true); do
          systemctl stop "$(systemd-escape -p --suffix=mount "$t")" || true
        done
        if left=$(grep -v '^NV' /proc/fs/nfsfs/volumes 2>/dev/null) && [ -n "$left" ]; then
          echo "NFS superblocks still alive before sleep:" >&2
          echo "$left" >&2
        fi
      '';
      preStop = ''
        marker=/run/nas-sleep.remount
        [ -e "$marker" ] || exit 0
        rm -f "$marker"
        # The network needs a moment after resume; give the server 15 s.
        for _ in $(seq 1 15); do
          if timeout 2 bash -c 'exec 3<>/dev/tcp/${server}/2049' 2>/dev/null; then
            systemctl start --no-block nas.target
            exit 0
          fi
          sleep 1
        done
        echo "NAS not reachable after resume, shares stay detached." >&2
      '';
    };

    security.polkit.extraConfig = lib.mkIf cfg.manual ''
      // NAS switch: let the desktop users mount and unmount the NAS shares.
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            subject.active &&
            ${builtins.toJSON users}.indexOf(subject.user) >= 0) {
          var unit = action.lookup("unit");
          var verb = action.lookup("verb");
          if (/^(media-nas\.mount|nas\.target|home-[^\/]+\.mount)$/.test(unit) &&
              (verb == "start" || verb == "stop")) {
            return polkit.Result.YES;
          }
        }
      });
    '';
  };
}
