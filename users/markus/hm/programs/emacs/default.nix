{ config, lib, pkgs, ... }:
{
  config = {
    services.emacs = {
      enable = true;
      client.enable = true;
      defaultEditor = true;
    };

    programs.emacs = {
      package = pkgs.emacs29;
      extraPackages = epkgs: [
        epkgs.bind-key
        epkgs.company
        epkgs.epresent
        epkgs.evil
        epkgs.evil-org
        epkgs.fira-code-mode
        epkgs.flycheck
        epkgs.haskell-mode
        epkgs.helm
        epkgs.lean-mode
        epkgs.lsp-ui
        epkgs.lsp-mode
        epkgs.lsp-haskell
        epkgs.lsp-treemacs
        epkgs.magit
        epkgs.org
	epkgs.pdf-tools
        epkgs.quelpa
        epkgs.quelpa-use-package
	epkgs.tempel
        epkgs.treemacs
        epkgs.treemacs-evil
        epkgs.use-package
      ];
      extraConfig = ''
        (setq inhibit-startup-message 1)

        (scroll-bar-mode -1)
        (tool-bar-mode -1)
        (tooltip-mode -1)
        (set-fringe-mode 10)

        (menu-bar-mode -1)

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
        (use-package pdf-tools
          :ensure t
          :magic ("%PDF" . pdf-view-mode)

	  :config
            (pdf-tools-install)
            (setq pdf-view-display-size 'fit-page)
            (add-hook 'pdf-view-mode-hook (lambda ()
                                            (pdf-view-auto-slice-minor-mode)
                                            (auto-revert-mode 1)))
            ;; Ensure Evil window management keybindings work in pdf-view-mode
            (with-eval-after-load 'evil
              (evil-set-initial-state 'pdf-view-mode 'normal)
              (evil-define-key 'normal pdf-view-mode-map
                ;; Keybindings for window management
                "C-w h" 'evil-window-left
                "C-w l" 'evil-window-right
                "C-w j" 'evil-window-down
                "C-w k" 'evil-window-up
                "C-w w" 'evil-window-next
                "C-w o" 'delete-other-windows)))
        (use-package helm
          :bind  ("M-x" . helm-M-x)
                 ("M-y" . helm-show-kill-ring)
                 ("C-x b" . helm-mini))
        (use-package helm-files
          :bind ("C-x C-f" . helm-find-files))
        (use-package flycheck
          :ensure t
          :init (global-flycheck-mode)
          :config (add-to-list 'display-buffer-alist
             `(,(rx bos "*Flycheck errors*" eos)
              (display-buffer-reuse-window
               display-buffer-in-side-window)
              (side            . bottom)
              (reusable-frames . visible)
              (window-height   . 0.15))))
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
            (add-hook 'org-mode-hook 'display-line-numbers-mode)
            (progn
              (setq org-agenda-files (list "~/Dokumente/RaphisNotizen/")))
          )
        (use-package evil-org
          :ensure t
          :after org
          :hook (org-mode . evil-org-mode)
          :config
            (require 'evil-org-agenda)
            (evil-org-agenda-set-keys)
          )
        (use-package epresent
          )
        (use-package haskell-mode
          :ensure t
          :config
              (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
              (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
              (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
              (add-hook 'haskell-mode-hook 'display-line-numbers-mode)
              (setq haskell-process-args-cabal-new-repl
                '("--ghc-options=-ferror-spans -fshow-loaded-modules"))
              (setq haskell-process-type 'cabal-new-repl)
              (setq haskell-stylish-on-save 't)
              (setq haskell-tags-on-save 't)
              (define-key haskell-mode-map (kbd "C-c m") 'haskell-process-reload-devel-main)
        )
        (use-package lsp-mode
          :init (setq lsp-keymap-prefix "C-c l")
          :hook (haskell-mode . lsp-deferred)
                (haskell-literate-mode . lsp-deferred)
          :commands (lsp lsp-deferred)
          :config
              (setq read-process-output-max (* 1024 1024))
              (setq gc-cons-threshold 100000000)
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
        (use-package fira-code-mode
          :custom (fira-code-mode-disabled-ligatures '("x"))  ; ligatures you don't want
          :config
            (set-face-attribute 'default nil :family "Fira Code" :weight 'medium :height 80)
          :hook prog-mode)
        (use-package lean-mode
          :ensure t)
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
        (use-package treemacs-evil
          :ensure t)
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
        (use-package evil
          :ensure t ;; install the evil package if not installed
          :init ;; tweak evil's configuration before loading it
            (setq evil-search-module 'evil-search)
            (setq evil-ex-complete-emacs-commands nil)
            (setq evil-vsplit-window-right t)
            (setq evil-split-window-below t)
            (setq evil-shift-round nil)
            (setq evil-want-C-u-scroll t)
          :config ;; tweak evil after loading it
            (evil-mode)

          ;; example how to map a command in normal mode (called 'normal state' in evil)
          (define-key evil-normal-state-map (kbd ", w") 'evil-window-vsplit))

        (setq display-line-numbers-type 'relative)

        ;; Configure Tempel
        (use-package tempel
          ;; Require trigger prefix before template name when completing.
          ;; :custom
          ;; (tempel-trigger-prefix "<")
        
          :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
                 ("M-*" . tempel-insert))
        
          :init
        
          ;; Setup completion at point
          (defun tempel-setup-capf ()
            ;; Add the Tempel Capf to `completion-at-point-functions'.
            ;; `tempel-expand' only triggers on exact matches. Alternatively use
            ;; `tempel-complete' if you want to see all matches, but then you
            ;; should also configure `tempel-trigger-prefix', such that Tempel
            ;; does not trigger too often when you don't expect it. NOTE: We add
            ;; `tempel-expand' *before* the main programming mode Capf, such
            ;; that it will be tried first.
            (setq-local completion-at-point-functions
                        (cons #'tempel-expand
                              completion-at-point-functions)))
        
          (add-hook 'conf-mode-hook 'tempel-setup-capf)
          (add-hook 'prog-mode-hook 'tempel-setup-capf)
          (add-hook 'text-mode-hook 'tempel-setup-capf)
        
          ;; Optionally make the Tempel templates available to Abbrev,
          ;; either locally or globally. `expand-abbrev' is bound to C-x '.
          ;; (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
          ;; (global-tempel-abbrev-mode)
        )
      '';
    };

    home.file.".emacs.d/templates".source = ./tempel-templates;
  };
}

