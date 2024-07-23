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
        (hash "A-s" (hash "t" ":scala-switch-main-test"
                          "i" ":scala-switch-main-it"
                          "e" ":scala-switch-main-e2e"
                          "M" ":scala-open-main"
                          "T" ":scala-open-test"
                          "I" ":scala-open-it"
                          "E" ":scala-open-e2e")
              "space" (hash "e" ":file-browser"
                            "E" ":file-browser-cwd"))))
