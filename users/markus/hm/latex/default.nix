{ config, lib, pkgs, ... }:
{
  config = {
    programs.texlive = {
      enable = true;
      extraPackages = (tpkgs: { inherit (tpkgs) collection-latex collection-xetex collection-langgerman eurosym fontaxes mathspec moderncv preprint academicons fontawesome5 opensans pgf pgfplots multirow arydshln koma-script enumitem fontspec exam iwona iwonamath xkeyval; });
    };
  };
}
