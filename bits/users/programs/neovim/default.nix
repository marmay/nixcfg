{ config, lib, pkgs, user, ... }:

let
  myPlugins = with pkgs.vimPlugins; [
    haskell-vim
    ghcid
    vim-hindent
    fugitive
    barbar-nvim
    toggleterm-nvim
    nvim-web-devicons
    LanguageClient-neovim
  ];
  baseConfig = builtins.readFile ./config.vim;
  lspConfig = builtins.readFile ./lsp.vim;
  themeConfig = builtins.readFile ./disco.vim;
  # orgmodeConfig = builtins.readFile ./orgmode.vim;
  vimConfig = baseConfig + lspConfig + themeConfig; # + orgmodeConfig;
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
