{
  trivialBuild,
  fetchFromGitHub,
  pkgs,
}:
trivialBuild rec {
  pname = "minuet-ai";
  version = "main-2025-02-09";
  src = fetchFromGitHub {
    owner = "milanglacier";
    repo = "minuet-ai.el";
    rev = "571aefc4ec1a99787860aad8649fda0ef311d8ce";
    hash = "sha256-sSaNC6Os9bZOV7eOKcgvaicQ2sj/ykCwathqnGYWxIo=";
  };
  packageRequires = with pkgs.emacsPackages; [
    dash
    plz
  ];
}