{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      git
      htop
      vim
      screen
      haskellPackages.cabal-install
      haskell-language-server
      ghc
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    services.vscode-server.enable = true;
    system.stateVersion = "24.05"; # Did you read the comment?
  };
}
