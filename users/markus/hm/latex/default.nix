{ config, lib, pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      symbola
    ];
    programs.texlive = {
      enable = true;
      extraPackages = (tpkgs: { inherit (tpkgs) animate background biblatex cnltx cntformats collection-latex collection-xetex collection-langgerman eurosym environ emoji everypage exsheets fontaxes framed lastpage makecell mathspec moderncv ninecolors media9 pdfprivacy pgfopts preprint ocgx2 academicons fontawesome5 opensans pgf pgfplots multirow arydshln koma-script enumitem fontspec exam standalone tasks ulem tabularray translations totcount iwona iwonamath xfrac xkeyval xstring wrapfig zref; });
    };
  };
}
