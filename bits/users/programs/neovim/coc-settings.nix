{
  "languageserver" = {
    "haskell" = {
      "command" = "haskell-language-server-wrapper";
      "args" = [ "--lsp" ];
      "rootPatterns" = [
        "stack.yaml"
        "hie.yaml"
        ".hie-bios"
        "BUILD.bazel"
        ".cabal"
        "cabal.project"
        "package.yaml"
      ];
      "filetypes" = [ "hs" "lhs" "haskell" ];
      "initializationOptions" = {
        "languageServerHaskell" = {
          "hlintOn" = true;
          "formattingProvider" = "fourmolu";
        };
      };
    };
  };

  "yank.highlight.duration" = 700;
}
