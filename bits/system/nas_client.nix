{ config, lib, pkgs, ... }:

let
  cfg = config.marmar.nas_client;
  nfsUnit = "media-nas.mount";

  # Two modes. Automatic: every mount is behind an automount and comes up on
  # first access (fine for machines that are always on the network). Manual:
  # nothing touches the network until nas.target is started, e.g. through the
  # NAS switch in xmonad; off-network the directories are plain local ones.
  automountOpts = [ "x-systemd.automount" "x-systemd.device-timeout=10s" "noauto" ];

  nfsOpts =
    if cfg.manual then [
      "noauto" "nofail" "_netdev"
      # Fail fast when the server is unreachable instead of hanging:
      "soft" "timeo=100" "retrans=3" "retry=0" "x-systemd.mount-timeout=20s"
      "x-systemd.required-by=nas.target"
    ] else automountOpts;

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
          device = "10.0.0.80:/export/media";
          fsType = "nfs";
          options = nfsOpts;
        };
      }
      // builtins.listToAttrs (lib.lists.concatMap mkLinks users);

    # Manual mode: one target that pulls in every mount, a clean unmount even
    # when the server is gone, and permission for the users to switch.
    systemd.targets.nas = lib.mkIf cfg.manual {
      description = "NAS shares mounted";
    };

    systemd.units."${nfsUnit}" = lib.mkIf cfg.manual {
      overrideStrategy = "asDropin";
      text = ''
        [Mount]
        LazyUnmount=yes
        ForceUnmount=yes
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
