{ config, inputs, ... }:
{
  config = {
    nixpkgs.config.allowUnsupportedSystem = true;
    nixpkgs.crossSystem.system = "armv7l-linux";
  };
}
