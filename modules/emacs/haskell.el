(setq lsp-haskell-process-wrapper-function
      (lambda (argv)
        (append
         (append (list "nix-shell" "-I" "." "--command" )
                 (list (mapconcat 'identity argv " ")))
         (list (concat (lsp-haskell--get-root) "/shell.nix")))))

(setq lsp-haskell-process-path-hie "hie-wrapper")

(use-package lsp-haskell)

(add-hook 'haskell-mode-hook #'lsp)
