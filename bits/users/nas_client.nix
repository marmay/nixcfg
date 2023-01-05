{ config, lib, pkgs, user, ... }:
{
  imports = [
    ../system/data.nix
  ];

  config.fileSystems = lib.mkIf config.sharedData.enable (
    let
      mkLink = target: source: lib.nameValuePair target { device = source; options = [ "bind" "_netdev" "comment=x-gvfs-hide" ]; };
      mkUserLink = n: mkLink "/home/${user}/${n}" "${config.sharedData.path}/Users/${user}/${n}";
      mkSharedLink = n: mkLink "/home/${user}/Gemeinsam/${n}" "${config.sharedData.path}/${n}";
    in
    builtins.listToAttrs [
      (mkUserLink "Bilder")
      (mkUserLink "Downloads")
      (mkUserLink "Dokumente")
      (mkUserLink "Schreibtisch")
      (mkUserLink "Videos")
      (mkUserLink "Vorlagen")
      (mkSharedLink "Bilder")
      (mkSharedLink "Dokumente")
      (mkSharedLink "E-Books")
      (mkSharedLink "Musik")
      (mkSharedLink "Spiele")
      (mkSharedLink "Videos")
    ]);
}

