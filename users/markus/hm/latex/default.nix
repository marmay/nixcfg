{ config, lib, pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      symbola
    ];
    programs.texlive = {
      enable = true;
      extraPackages = (tpkgs: { inherit (tpkgs) cnltx cntformats collection-latex collection-xetex collection-langgerman eurosym environ emoji exsheets fontaxes mathspec moderncv pgfopts preprint academicons fontawesome5 opensans pgf pgfplots multirow arydshln koma-script enumitem fontspec exam tasks ulem translations iwona iwonamath xkeyval wrapfig; });
    };
  };
}
