{ config, lib, pkgs, ... }:
{
  imports = [
    ./data.nix
  ];

  config = {
    fileSystems."/media/nas" = {
      device = "10.0.0.80:/export/media";
      fsType = "nfs";
    };

    sharedData.enable = true;
  };
}
