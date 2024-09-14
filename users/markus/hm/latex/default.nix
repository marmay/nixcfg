{ config, lib, pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      symbola
    ];
    programs.texlive = {
      enable = true;
      extraPackages = (tpkgs: { inherit (tpkgs) background cnltx cntformats collection-latex collection-xetex collection-langgerman eurosym environ emoji everypage exsheets fontaxes mathspec moderncv ninecolors pdfprivacy pgfopts preprint academicons fontawesome5 opensans pgf pgfplots multirow arydshln koma-script enumitem fontspec exam tasks ulem tabularray translations iwona iwonamath xfrac xkeyval wrapfig; });
    };
  };
}
