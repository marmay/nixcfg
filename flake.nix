{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
  };
  inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, agenix, flake-utils, ... }:
  let
    mynixpkgs = system: import nixpkgs ({
      inherit system;
      config = {
        allowUnfree = true;
      };
    });
    mkUserPc = { path, system ? "x86_64-linux", extra-modules ? [] }: nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          home-manager.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          agenix.nixosModules.default
          ./bits/system
          ./users
          path
        ] ++ extra-modules;
      };
  in {
    nixosConfigurations = {
      buki = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/buki
          agenix.nixosModules.default
        ];
      };
      keller = mkUserPc { path = ./hosts/keller; };
      nas = mkUserPc { path = ./hosts/nas; };
      notebook = mkUserPc { path = ./hosts/notebook; };
      raphberry = mkUserPc {
        path = ./hosts/raphberry;
        system = "aarch64-linux";
        extra-modules = [
          (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
          nixos-hardware.nixosModules.raspberry-pi-4
          ./bits/system/rpi.nix
        ];
      };
    };

  } // flake-utils.lib.eachDefaultSystem (system: let pkgs = mynixpkgs system; in {
    legacyPackages = pkgs;

    devShells.ihp = pkgs.mkShell {
      buildInputs = with pkgs; [
        cachix
        direnv
        gnumake
        tmux
      ];
      shellHook = ''
        eval "$(direnv hook bash)"
      '';
    };
  });
}
