{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-22.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, agenix, flake-utils, ... }:
  let
    mkUserPc = { path, system ? "x86_64-linux", extra-modules ? [] }: nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          home-manager.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          agenix.nixosModules.default
          path
        ] ++ extra-modules;
      };
    mynixpkgs = system: import nixpkgs ({
      inherit system;
      config = {
        allowUnfree = true;
      };
    });
  in {
    nixosConfigurations = {
      buki = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
          (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel.nix")
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
