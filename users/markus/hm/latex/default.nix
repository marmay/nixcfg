{ config, lib, pkgs, ... }:
{
  config = {
    programs.texlive = {
      enable = true;
      extraPackages = (tpkgs: { inherit (tpkgs) collection-latex collection-xetex collection-langgerman moderncv preprint academicons fontawesome5 pgf multirow arydshln koma-script enumitem fontspec exam; });
    };
  };
}