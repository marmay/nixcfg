{ config, lib, pkgs, ... }:
{
  options.profiles.latex = lib.mkEnableOption "LaTeX environment";

  config = lib.mkIf config.profiles.latex {
    home.packages = with pkgs; [
      nerd-fonts.fira-mono
    ];
    programs.texlive = {
      enable = true;
      extraPackages = (tpkgs: {
        inherit (tpkgs)
	  scheme-medium
	  academicons
	  animate
	  arydshln
	  background
	  biblatex
	  capt-of
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
          mdframed
	  media9
	  moderncv
	  multirow
	  needspace
          ninecolors
	  numprint
	  ocgx2
	  opensans
	  pdfcol
	  pdfprivacy
	  pgf
	  pgfmath-xfp
	  pgfopts
	  pgfplots
	  preprint
	  standalone
	  tabularray
	  tasks
          tcolorbox
	  tikzfill
	  tikzpeople
	  tkz-base
	  tkz-euclide
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
