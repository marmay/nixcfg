{ config, lib, pkgs, ... }:
let user = "markus"; in
{
  config = {
    age.secrets = {
      "${user}Password" = {
        file = ../../secrets/markus/users/${user};
      };
    };

    users.users.${user} = {
      uid = 1000;
      isNormalUser = true;
      passwordFile = config.age.secrets."${user}Password".path;
      extraGroups = [
        "users"
        "cdrom"
      ];
    };

    home-manager.users.${user} = {
      imports = (import ../../bits/users/modules.nix);

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "21.11";
        packages = with pkgs; [];
      };

      accounts.email.accounts."markus.mayr@outlook.com" = {
        primary = true;
        realName = "Markus Mayr";
        address = "markus.mayr@outlook.com";
        flavor = "outlook.office365.com";
      } // (import ../../bits/users/mail/mailClients.nix { maxAge = 30; });

      accounts.email.accounts."markus@bu-ki.at" =
        (import ../../bits/users/mail/mkBuki.nix ({
          realName = "Markus Mayr";
          address = "markus@bu-ki.at";
        }));

      programs.emacs = {
        enable = true;
        extraPackages = epkgs: [
          epkgs.haskell-mode
          epkgs.linum-relative
          epkgs.lsp-ui
          epkgs.lsp-mode
          epkgs.lsp-haskell
          epkgs.lsp-treemacs
          epkgs.org
          epkgs.quelpa
          epkgs.quelpa-use-package
          epkgs.treemacs
          epkgs.use-package
        ];
        extraConfig = ''
          (eval-when-compile
            (require 'use-package))
          (use-package quelpa
            :ensure t
            :config
            (setq quelpa-update-melpa-p nil))
          (use-package quelpa-use-package
            :ensure t)
          (use-package org
            :mode (("org$" . org-mode))
            :ensure org-mode
            :config
            (progn
              (setq org-agenda-files (list "~/Dokumente/Notizen/"))
            ))
          (use-package lsp-mode
            :init (setq lsp-keymap-prefix "C-c l")
            :hook (haskell-mode . lsp-deferred)
                  (haskell-literate-mode . lsp-deferred)
            :commands (lsp lsp-deferred))
          (use-package lsp-ui
            :commands lsp-ui-mode)
          (use-package lsp-haskell
            :config
            (setf lsp-haskell-server-path "haskell-language-server"))
          (use-package copilot
            :quelpa (copilot :fetcher github
                             :repo "zerolfx/copilot.el"
                             :branch "main"
                             :files ("dist" "*.el"))
            :hook
              (prog-mode . copilot-mode)
              (org-mode . copilot-mode)
            :config
              (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
              (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))
          (use-package linum-relative
            :config
            (linum-relative-global-mode))
        '';
      };
    };
  };
}
