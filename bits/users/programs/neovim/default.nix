{ config, lib, pkgs, user, ... }:

let
  myPlugins = with pkgs.vimPlugins; [
    copilot-vim
    haskell-vim
    ghcid
    vim-hindent
    fugitive
    barbar-nvim
    toggleterm-nvim
    nvim-web-devicons
    nvim-base16
    LanguageClient-neovim
  ];
  baseConfig = builtins.readFile ./config.vim;
  lspConfig = builtins.readFile ./lsp.vim;
  vimConfig = baseConfig + lspConfig;
  lspSettings = builtins.toJSON (import ./lsp_settings.nix);
in
{
  config.home-manager.users.${user} = { ... } : {
    programs.neovim = {
      enable = true;
      extraConfig = vimConfig;
      plugins = myPlugins;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    xdg.configFile."nvim/settings.json".text = lspSettings;
  };
}
