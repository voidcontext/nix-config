(require "helix/configuration.scm")

;; --------------------------------------------- COPIED
(require-builtin helix/core/keymaps as helix.keymaps.)

;;@doc
;; Add keybinding to the global default
(define (add-global-keybinding map)

  ;; Copy the global ones
  (define global-bindings (get-keybindings))
  (helix.keymaps.helix-merge-keybindings
   global-bindings
   (~> map (value->jsexpr-string) (helix.keymaps.helix-string->keymap)))

  (keybindings global-bindings)

  ;; Merge keybindings
  ; (helix.keymaps.helix-merge-keybindings
  ;  helix.keymaps.*global-keybinding-map*
  ;  (~> map (value->jsexpr-string) (helix.keymaps.helix-string->keymap)))
  )

;; --------------------------------------------------------- END COPY

(add-global-keybinding
  (hash "normal" 
        (hash "C-t" 
              (hash "s" ":scala-switch-main-test"))))
