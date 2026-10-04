{ config, lib, pkgs, ... }:
{
  options.profiles.dev = lib.mkEnableOption "Development tasks";

  config = lib.mkIf config.profiles.dev {
    programs = {
      fish.enable = true;
      htop.enable = true;
      emacs.enable = true;
      wezterm.enable = true;
      git = {
        enable = true;
        settings = {
          user.name = "Markus Mayr";
          user.email = "markus.mayr@outlook.com";
        };
      };
    };
    home.packages = with pkgs; [
      # This is a light standard setup that carries my needs
      # for roam, in particular.
      (ghc.withPackages (hsPkgs: with hsPkgs; [
        aeson
        extra
        containers
        text
        yaml
      ]))
      cabal-install
      haskell-language-server
      # This keeps the NixOS hls compatible with my flake HLS setup for emacs.
      (pkgs.runCommand "hls-wrapper-as-hls" {} ''
        mkdir -p $out/bin
        ln -s ${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper \
              $out/bin/haskell-language-server
      '')
    ];
  };
}
