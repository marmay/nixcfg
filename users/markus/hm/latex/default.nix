{ config, lib, pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      symbola
    ];
    programs.texlive = {
      enable = true;
      extraPackages = (tpkgs: {
        inherit (tpkgs)
	  academicons
	  animate
	  arydshln
	  background
	  biblatex
	  cnltx
	  cntformats
	  collection-langgerman
	  collection-latex
	  collection-xetex
	  emoji
	  enumitem
	  environ
	  eurosym
	  everypage
	  exam
	  exsheets
	  fontawesome5
	  fontaxes
	  fontspec
	  framed
	  iwona
	  iwonamath
	  koma-script
	  lastpage
	  listings
	  makecell
	  mathspec
	  media9
	  moderncv
	  multirow
	  ninecolors
	  ocgx2
	  opensans
	  pdfprivacy
	  pgf
	  pgfopts
	  pgfplots
	  preprint
	  standalone
	  tabularray
	  tasks
	  totcount
	  translations
	  ulem
	  wrapfig
	  xfrac
	  xkeyval
	  xstring
	  zref
	;
      });
    };
  };
}
