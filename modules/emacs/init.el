;; global variables
(setq
 inhibit-startup-screen t
 create-lockfiles nil
 make-backup-files nil
 auto-save-default nil
 column-number-mode t
 scroll-error-top-bottom t
 sentence-end-double-space nil
 mac-command-modifier 'super
 show-paren-delay 0
 multi-term-program (substitute-in-file-name "${HOME}/.nix-profile/bin/zsh")
 gc-cons-threshold 100000000
 read-process-output-max (* 1024 1024)
)

(setenv "PATH" (concat "$HOME/.nix-profile/bin:" (getenv "PATH")))

(defvar user-home)
(setq user-home (getenv "HOME"))

(setq-default
 show-trailing-whitespace t)

(when (version<= "26.0.50" emacs-version )
  (global-display-line-numbers-mode))

(set-face-attribute 'default nil
                :font "Fira Mono" :height @font-size@ :weight 'regular :width 'regular)

(show-paren-mode 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-auto-revert-mode 1)
(winner-mode 1)

;; buffer local variables
(setq-default
 indent-tabs-mode nil
 tab-width 8
 c-basic-offset 2
 standard-indent 2)

;; modes
(electric-indent-mode 0)

;; global keybindings
(global-unset-key (kbd "C-z"))
(global-unset-key [mouse-2])
(global-set-key (kbd "C-c C--") 'hs-hide-block)
(global-set-key (kbd "C-c C-=") 'hs-show-block)
(global-set-key (kbd "C-c M--") 'hs-hide-all)
(global-set-key (kbd "C-c M-=") 'hs-show-all)

(global-set-key (kbd "C-x a a") 'align-regexp)
(global-set-key (kbd "C-x a s") 'sort-lines)
(global-set-key (kbd "C-x t w") 'delete-trailing-whitespace)
(global-set-key (kbd "C-x w s") 'window-swap-states)

(global-set-key (kbd "C-z r r") 'replace-regexp)
(global-set-key (kbd "C-z r s") 'replace-string)

(global-set-key (kbd "C-c C-d") 'lsp-ui-doc-show)


(add-hook 'org-mode-hook (lambda () (flyspell-mode 1)))
(add-hook 'markdown-mode-hook (lambda () (flyspell-mode 1)))
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)

;; the package manager
(require 'package)

(package-initialize)
(require 'use-package)

;; Packages

(use-package gruvbox-theme)
(load-theme 'gruvbox-dark-soft t)

(use-package vterm)
(add-hook 'vterm-mode-hook
          (lambda ()
            (setq show-trailing-whitespace nil)
            (display-line-numbers-mode -1)))

(use-package multi-vterm)

(use-package which-key)

(use-package projectile
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))


(use-package multiple-cursors)
(use-package default-text-scale
  :bind (("C-c +" . default-text-scale-increase)
         ("C-c -" . default-text-scale-decrease)
         ("C-c 0" . default-text-scale-reset)))

;; ###############################
;; common.el

(use-package undo-tree
  :diminish undo-tree-mode
  :config (global-undo-tree-mode)
  :bind ("s-/" . undo-tree-visualize))

(use-package highlight-symbol
  :diminish highlight-symbol-mode
  :commands highlight-symbol
  :bind ("s-h" . highlight-symbol))

(use-package ace-window
  :delight
  :bind
  ("M-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; ###############################
;; git.el

(use-package git-gutter
  :diminish git-gutter-mode
  :config (global-git-gutter-mode))

(use-package magit
  :commands magit-status magit-blame
  :init (setq
         magit-revert-buffers nil
         global-git-commit-mode t)
  :bind (("s-g" . magit-status)
         ("s-b" . magit-blame)))

(require 'git-commit)

;; ###############################
;; treemacs.el

(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs              (if (executable-find "python") 3 0)
          treemacs-deferred-git-apply-delay   0.5
          treemacs-display-in-side-window     t
          treemacs-file-event-delay           5000
          treemacs-file-follow-delay          0.2
          treemacs-follow-after-init          t
          treemacs-follow-recenter-distance   0.1
          treemacs-git-command-pipe           ""
          treemacs-goto-tag-strategy          'refetch-index
          treemacs-indentation                2
          treemacs-indentation-string         " "
          treemacs-is-never-other-window      nil
          treemacs-max-git-entries            5000
          treemacs-no-png-images              nil
          treemacs-no-delete-other-windows    t
          treemacs-project-follow-cleanup     nil
          treemacs-persist-file               (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-recenter-after-file-follow nil
          treemacs-recenter-after-tag-follow  nil
          treemacs-show-cursor                nil
          treemacs-show-hidden-files          t
          treemacs-silent-filewatch           nil
          treemacs-silent-refresh             nil
          treemacs-sorting                    'alphabetic-asc
          treemacs-space-between-root-nodes   t
          treemacs-tag-follow-cleanup         t
          treemacs-tag-follow-delay           1.5
          treemacs-width                      35)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null (executable-find "python3"))))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-icons-dired
  :config (treemacs-icons-dired-mode))

(use-package direnv
  :config
  (direnv-mode))

(use-package counsel
  :bind
  ("C-c /" . counsel-git-grep)
  ("C-c c" . counsel-compile)
  ("C-c f l" . counsel-locate)
  ("C-c f r" . counsel-recentf)
  ("C-h f" . counsel-describe-function)
  ("C-h v" . counsel-describe-variable)
  ("C-h l" . counsel-find-library)
  ("C-h i" . counsel-info-lookup-symbol)
  ("C-x 8 RET" . counsel-unicode-char)
  ("C-x C-f" . counsel-find-file)
  ("M-x" . counsel-M-x))

(use-package counsel-projectile
  :config
  (counsel-projectile-mode))

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :delight
  :hook
  (prog-mode . rainbow-mode))

(use-package expand-region
  :bind
  ("C-=" . 'er/expand-region))

(use-package flycheck
  :init
  (global-flycheck-mode))


(use-package company
  :delight
  :hook
  (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0
        company-minimum-prefix-length 2
        company-show-numbers t
        company-tooltip-align-annotations t
        company-dabbrev-downcase nil))

(use-package company-quickhelp
  :bind
  (:map company-active-map
        ("M-h" . company-quickhelp-manual-begin))
  :config
  (setq company-quickhelp-delay nil)
  (company-quickhelp-mode +1))

(use-package company-restclient
  :config
  (push 'company-restclient company-backends))

(use-package ivy
  :delight
  :config
  (setq ivy-use-virtual-buffers t)
  (ivy-mode 1))

(use-package ivy-rich
  :config
  (ivy-rich-mode +1))

(use-package sql-indent
  :after sql-mode
  :init (add-hook 'sql-mode-hook 'sql-indent))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-l"
        lsp-diagnostic-package :flycheck
        lsp-rust-analyzer-proc-macro-enable t
        lsp-rust-analyzer-experimental-proc-attr-macros t
        )
  :config
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.nix-shell\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]result\\'")
  :hook  (scala-mode . lsp)
         (lsp-mode . lsp-lens-mode))

(use-package lsp-treemacs
  :bind
  ("C-c e t" . lsp-treemacs-errors-list))

(use-package lsp-ui
  :init
;;  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-ui-sideline-diagnostic-max-lines 20)
  (setq lsp-ui-doc-position 'at-point)
;;  (setq lsp-ui-doc-header t)
  (setq lsp-ui-doc-include-signature t)
  )

(use-package yasnippet
  :config
  (yas-global-mode 1))


;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)


(use-package yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package terraform-mode)

(use-package plantuml-mode
  :init
  (setq plantuml-executable-path (concat user-home "/.nix-profile/bin/plantuml"))
  (setq plantuml-default-exec-mode 'executable)
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((cider-shadow-cljs-default-options . "app"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


@extraConfig@

