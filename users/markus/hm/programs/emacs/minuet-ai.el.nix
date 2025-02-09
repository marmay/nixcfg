{
  trivialBuild,
  fetchFromGitHub,
  all-the-icons,
}:
trivialBuild rec {
  pname = "minuet-ai";
  version = "main-2025-02-09";
  src = fetchFromGitHub {
    owner = "milanglacier";
    repo = "minuet-ai.el";
    rev = "571aefc4ec1a99787860aad8649fda0ef311d8ce";
    hash = "sha256-xxx";
  };
  # elisp dependencies
  propagatedUserEnvPkgs = [
    all-the-icons
  ];
  buildInputs = propagatedUserEnvPkgs;
}
