{ config, lib, pkgs, ... }:

let
  myPlugins = with pkgs.vimPlugins; [
    copilot-vim
    haskell-vim
    ghcid
    vim-hindent
    fugitive
    lualine-nvim
    barbar-nvim
    toggleterm-nvim
    nvim-web-devicons
    nvim-base16
    nvim-treesitter.withAllGrammars
    nvim-tree-lua
    orgmode
    LanguageClient-neovim
  ];
  baseConfig = builtins.readFile ./config.vim;
  lspConfig = builtins.readFile ./lsp.vim;
  orgModeConfig = builtins.readFile ./orgmode.vim;
  vimConfig = baseConfig + orgModeConfig + lspConfig;
  treeConfig = builtins.readFile ./tree.lua;
  lualineConfig = builtins.readFile ./lualine.lua;
  vimLuaConfig = treeConfig + lualineConfig;
  lspSettings = builtins.toJSON (import ./lsp_settings.nix);
in
{
  options.marmar.neovim.enable = mkEnableOption "neovim marmar configuration";

  config = lib.mkIf config.marmar.neovim.enable {
    home.packages = with pkgs; [
      nodejs-16_x
    ];
    programs.neovim = {
      enable = true;
      extraConfig = vimConfig;
      extraLuaConfig = vimLuaConfig;
      plugins = myPlugins;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    xdg.configFile."nvim/settings.json".text = lspSettings;
  };
}
