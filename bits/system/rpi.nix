{ config, inputs, ... }:
{
  imports = [
    ./inputs.nixpkgs.nixos.modules.installer.sd-card.sd-image-raspberrypi.nix
  ];

  config = {
    nixpkgs.config.allowUnsupportedSystem = true;
    nixpkgs.crossSystem.system = "armv7l-linux";
  };
}
