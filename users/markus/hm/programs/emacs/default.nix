{ config, lib, pkgs, ... }:
{
  config = {
    programs.emacs = {
      extraPackages = epkgs: [
        epkgs.bind-key
        epkgs.company
        epkgs.haskell-mode
        epkgs.linum-relative
        epkgs.lsp-ui
        epkgs.lsp-mode
        epkgs.lsp-haskell
        epkgs.lsp-treemacs
        epkgs.magit
        epkgs.org
        epkgs.org-kanban
        epkgs.quelpa
        epkgs.quelpa-use-package
        epkgs.treemacs
        epkgs.use-package
      ];
      extraConfig = ''
        (eval-when-compile
          (require 'use-package))
        (use-package bind-key
          :ensure t
          :config
            (add-to-list 'same-window-buffer-names "*Personal Keybindings*"))
        (use-package quelpa
          :ensure t
          :config
          (setq quelpa-update-melpa-p nil))
        (use-package quelpa-use-package
          :ensure t)
        (use-package company
          :after lsp-mode
          :hook (prog-mode . company-mode)
                (org-mode . company-mode)
          :bind (:map company-active-map
                 ("C-n" . company-select-next)
                 ("C-p" . company-select-previous))
          :config
            (setq company-idle-delay 0.3)
            (global-company-mode t))
        (use-package org
          :mode (("org$" . org-mode))
          :ensure org-mode
          :config
          (progn
            (setq org-agenda-files (list "~/Dokumente/Notizen/"))
          ))
        (use-package org-kanban
          )
        (use-package lsp-mode
          :init (setq lsp-keymap-prefix "C-c l")
          :hook (haskell-mode . lsp-deferred)
                (haskell-literate-mode . lsp-deferred)
          :commands (lsp lsp-deferred)
        )
        (use-package lsp-ui
          :hook (lsp-mode . lsp-ui-mode)
          :commands lsp-ui-mode
          :config
            (setq lsp-ui-doc-enable t)
            (setq lsp-ui-doc-show-with-cursor t)
        (setq lsp-ui-sideline-enable t)
        (setq lsp-ui-sideline-show-hover t)
            (setq lsp-ui-sideline-show-diagnostics t))
        (use-package lsp-haskell
          :config
            (setf lsp-haskell-formatting-provider "fourmolu")
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
        (use-package treemacs
          :ensure t
          :defer t
          :init
          (with-eval-after-load 'winum
            (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
          :config
          (progn
            (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
                  treemacs-deferred-git-apply-delay        0.5
                  treemacs-directory-name-transformer      #'identity
                  treemacs-display-in-side-window          t
                  treemacs-eldoc-display                   'simple
                  treemacs-file-event-delay                2000
                  treemacs-file-extension-regex            treemacs-last-period-regex-value
                  treemacs-file-follow-delay               0.2
                  treemacs-file-name-transformer           #'identity
                  treemacs-follow-after-init               t
                  treemacs-expand-after-init               t
                  treemacs-find-workspace-method           'find-for-file-or-pick-first
                  treemacs-git-command-pipe                ""
                  treemacs-goto-tag-strategy               'refetch-index
                  treemacs-header-scroll-indicators        '(nil . "^^^^^^")
                  treemacs-hide-dot-git-directory          t
                  treemacs-indentation                     2
                  treemacs-indentation-string              " "
                  treemacs-is-never-other-window           nil
                  treemacs-max-git-entries                 5000
                  treemacs-missing-project-action          'ask
                  treemacs-move-forward-on-expand          nil
                  treemacs-no-png-images                   nil
                  treemacs-no-delete-other-windows         t
                  treemacs-project-follow-cleanup          nil
                  treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
                  treemacs-position                        'left
                  treemacs-read-string-input               'from-child-frame
                  treemacs-recenter-distance               0.1
                  treemacs-recenter-after-file-follow      nil
                  treemacs-recenter-after-tag-follow       nil
                  treemacs-recenter-after-project-jump     'always
                  treemacs-recenter-after-project-expand   'on-distance
                  treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
                  treemacs-project-follow-into-home        nil
                  treemacs-show-cursor                     nil
                  treemacs-show-hidden-files               t
                  treemacs-silent-filewatch                nil
                  treemacs-silent-refresh                  nil
                  treemacs-sorting                         'alphabetic-asc
                  treemacs-select-when-already-in-treemacs 'move-back
                  treemacs-space-between-root-nodes        t
                  treemacs-tag-follow-cleanup              t
                  treemacs-tag-follow-delay                1.5
                  treemacs-text-scale                      nil
                  treemacs-user-mode-line-format           nil
                  treemacs-user-header-line-format         nil
                  treemacs-wide-toggle-width               70
                  treemacs-width                           35
                  treemacs-width-increment                 1
                  treemacs-width-is-initially-locked       t
                  treemacs-workspace-switch-cleanup        nil)

            ;; The default width and height of the icons is 22 pixels. If you are
            ;; using a Hi-DPI display, uncomment this to double the icon size.
            ;;(treemacs-resize-icons 44)

            (treemacs-follow-mode t)
            (treemacs-filewatch-mode t)
            (treemacs-fringe-indicator-mode 'always)
            (when treemacs-python-executable
              (treemacs-git-commit-diff-mode t))

            (pcase (cons (not (null (executable-find "git")))
                         (not (null treemacs-python-executable)))
              (`(t . t)
               (treemacs-git-mode 'deferred))
              (`(t . _)
               (treemacs-git-mode 'simple)))

            (treemacs-hide-gitignored-files-mode nil))
          :bind
          (:map global-map
                ("M-0"       . treemacs-select-window)
                ("C-x t 1"   . treemacs-delete-other-windows)
                ("C-x t t"   . treemacs)
                ("C-x t d"   . treemacs-select-directory)
                ("C-x t B"   . treemacs-bookmark)
                ("C-x t C-t" . treemacs-find-file)
                ("C-x t M-t" . treemacs-find-tag)))

      '';
    };
  };
}

