args@{config, lib, pkgs, ... }:
let user = "marion"; in
{
  imports = [
    ../../bits/system/gnome.nix
  ];

  config = {
    home-manager.users.${user} = {
      programs = {
        firefox.enable = true;
      };
      home.packages = with pkgs; [
        calibre
        libreoffice
      ];
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];
    #xdg.configFile."geary/account_01".source = ./geary_account_gmail;
    #xdg.configFile."geary/account_02".source = ./geary_account_kl;
    #xdg.configFile."geary/account_03".source = ./geary_account_homepage;
  };
}

