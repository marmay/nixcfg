{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-24.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
  };
  inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware/master";
  };
  inputs.simple-nixos-mailserver = {
    url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    inputs.nixpkgs-24_05.follows = "nixpkgs";
  };
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";

  outputs = { self, nixpkgs, home-manager, nixos-hardware, agenix, simple-nixos-mailserver, vscode-server, flake-utils, ... }:
  let
    mynixpkgs = system: import nixpkgs ({
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        (final: prev: {
          xsecurelock = prev.xsecurelock.overrideAttrs (oldAttrs: {
            configureFlags = [
              "--with-pam-service-name=xscreensaver"
              "--with-xscreensaver=${final.xscreensaver}/bin/xscreensaver"
            ];
          });
        })
      ];
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
      aws = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/aws
          home-manager.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          (nixpkgs + "/nixos/modules/virtualisation/amazon-image.nix")
          vscode-server.nixosModules.default
          agenix.nixosModules.default
        ];
      };
      bu-ki = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/bu-ki
          agenix.nixosModules.default
          simple-nixos-mailserver.nixosModule
          vscode-server.nixosModules.default
        ];
      };
      keller = mkUserPc { path = ./hosts/keller; };
      nas = mkUserPc { path = ./hosts/nas; };
      mnb = mkUserPc {
        path = ./hosts/mnb;
        extra-modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-x13
          nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
          nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga-3th-gen
        ];
      };
      notebook = mkUserPc { path = ./hosts/notebook; };
      raphberry = mkUserPc {
        path = ./hosts/raphberry;
        system = "aarch64-linux";
        extra-modules = [
          (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
      camberry = nixpkgs.lib.nixosSystem {
        system = "armv6l-linux";
        modules = [
          ./hosts/camberry
          (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix")
        ];
      };
      carpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/carpi
          (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
          #nixos-hardware.nixosModules.raspberry-pi-4
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
