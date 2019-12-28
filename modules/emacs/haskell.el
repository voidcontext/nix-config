(setq lsp-haskell-process-path-hie "hie-wrapper")

(use-package lsp-haskell)

(add-hook 'haskell-mode-hook #'lsp)
