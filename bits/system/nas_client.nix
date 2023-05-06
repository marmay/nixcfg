{ config, lib, pkgs, ... }:

let
  mkLink = target: source: lib.nameValuePair target { device = source; options = [ "bind" "_netdev" "comment=x-gvfs-hide" ]; };
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
  options.marmar.nas_client = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Make this device a NAS client";
  };

  config = lib.mkIf config.marmar.nas_client
    {
      fileSystems =
        (({
          "/media/nas" = {
            device = "10.0.0.80:/export/media";
            fsType = "nfs";
          };
        })
        // (builtins.listToAttrs (lib.lists.concatMap mkLinks users)));
    };
}
