{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager.url = "github:nix-community/home-manager/release-22.11";

  outputs = { self, nixpkgs, home-manager, agenix, ... }:
  let
    mkUserPc = path: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          agenix.nixosModule
          path
        ];
      };
  in {
    nixosConfigurations = {
      buki = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/buki
          agenix.nixosModule
        ];
      };
      keller = mkUserPc ./hosts/keller;
      nas = mkUserPc ./hosts/nas;
      notebook = mkUserPc ./hosts/notebook;
    };
  };
}
