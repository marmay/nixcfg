{ config, lib, pkgs, ... }:
{
  options.profiles.agda = lib.mkEnableOption "Agda development environment";

  config = lib.mkIf config.profiles.agda {
    programs.emacs = {
      extraPackages = epkgs: [
        epkgs.agda-input
        epkgs.agda2-mode
      ];
    };
    home.file.".emacs.d/agda.el".text = ''
      (use-package agda-input
        )
      (use-package agda2-mode
        )
    '';

    home.packages = with pkgs; [
      (pkgs.agda.withPackages (p: [ p.standard-library ]))
    ];
  };
}
    