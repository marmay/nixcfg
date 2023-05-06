{ config, lib, pkgs, ... }:
{
  options.marmar.haskell = lib.mkEnableOption "haskell.nix support";

  config = lib.mkIf config.marmar.haskell {
    nix.settings = {
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
      substituters = [
        "https://cache.iog.io/"
      ];
    };
  };
}
