{
  trivialBuild,
  fetchFromGitHub,
  pkgs,
}:
trivialBuild rec {
  pname = "minuet-ai";
  version = "0.5.4";
  src = fetchFromGitHub {
    owner = "milanglacier";
    repo = "minuet-ai.el";
    rev = "8e4075713885f7ec7253936e3e74c7860ce7f77f";
    hash = "sha256-R8h/tH4qWQnjb2AyZonKCz7OhmuFV4i1TbuydbUJA2U=";
  };
  packageRequires = with pkgs.emacsPackages; [
    dash
    plz
  ];
}