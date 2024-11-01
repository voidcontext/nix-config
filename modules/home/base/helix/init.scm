(require "helix/configuration.scm")

;; --------------------------------------------- COPIED
(require-builtin helix/core/keymaps as helix.keymaps.)

(require "keymaps.scm")

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
              "A-d" (hash "t" ":clojure-switch-main-test"
                          "i" ":clojure-switch-main-it"
                          "e" ":clojure-switch-main-e2e"
                          "M" ":clojure-open-main"
                          "T" ":clojure-open-test"
                          "I" ":clojure-open-it"
                          "E" ":clojure-open-e2e")
              "space" (hash "e" ":file-browser"
                            "E" ":file-browser-cwd"))))
