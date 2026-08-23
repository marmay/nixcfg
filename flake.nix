{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
  };
  inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware/master";
  };
  inputs.competences = {
    url = "github:marmay/competences";
  };
  inputs.davinci-convert = {
    url = "github:marmay/davinci-convert";
  };
  inputs.nix-minecraft = {
    url = "github:Infinidoge/nix-minecraft";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.bghorn = {
    url = "git+file:///home/markus/Dokumente/Repos/bghorn.ac.at";
  };
  inputs.marmay-auth = {
    url = "github:marmay/marmay-auth";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, agenix, competences, flake-utils, davinci-convert, nix-minecraft, bghorn, marmay-auth, ... }@inputs:
  let
    myOverlays = (import ./bits/overlays/all.nix);
    mkUserPc = { path, system ? "x86_64-linux", extra-modules ? [] }: nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {
	  inherit inputs;
	};
        modules = [
          home-manager.nixosModules.default
          {
	    nixpkgs.config.allowUnfree = true;
	    nixpkgs.overlays = [ self.overlays.default ];
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
    overlays = { default = nixpkgs.lib.composeManyExtensions myOverlays; };
    nixosConfigurations = {
      bu-ki = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
	  inherit inputs;
	};
        modules = [
          ./hosts/bu-ki
          agenix.nixosModules.default
	  competences.nixosModules.competences
	  bghorn.nixosModules.bghorn-backend
	  bghorn.nixosModules.bghorn-builder
	  bghorn.nixosModules.bghorn-proxy
	  bghorn.nixosModules.bghorn-publisher
	  marmay-auth.nixosModules.marmay-auth
        ];
      };
      keller = mkUserPc {
        path = ./hosts/keller;
	extra-modules = [
	  nix-minecraft.nixosModules.minecraft-servers
	];
      };
      nas = mkUserPc {
        path = ./hosts/nas;
      };
      mnb = mkUserPc {
        path = ./hosts/mnb;
        extra-modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga-3th-gen
        ];
      };
      notebook = mkUserPc {
        path = ./hosts/notebook;
      };
      surface = mkUserPc {
        path = ./hosts/surface;
	system = "aarch64-linux";
	extra-modules = [
	  nixos-hardware.nixosModules.microsoft-surface-pro-intel
	];
      };
    };
  } // flake-utils.lib.eachDefaultSystem (system: {
    legacyPackages = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.overlays = [ self.overlays.default ];
    };
  });
}
