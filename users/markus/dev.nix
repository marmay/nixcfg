args@{ config, lib, pkgs, ... }:
let user = "markus"; in
{
  imports =
    let withArgs = path: extra: (import path (args // { user = user; } // extra));
    in
  [
    (withArgs ../../bits/users/programs/neovim {})
    ../../bits/system/haskell.nix
  ];

  config.nix.settings.trusted-users = [ user ];
  config.home-manager.users.${user} = {
    programs = {
      fish.enable = true;
      htop.enable = true;
      git = {
        enable = true;
        userName = "Markus Mayr";
        userEmail = "markus.mayr@outlook.com";
      };
    };
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
