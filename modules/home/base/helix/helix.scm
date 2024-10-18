(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))
(require "helix/editor.scm")

(define felis-path "@felis@")
(define broot-path "@broot@")

(provide open-helix-scm )
;;@doc
;; Open the helix.scm file
(define (open-helix-scm)
  (helix.open (helix.static.get-helix-scm-path)))

;; Modules

(require "scala.scm")
(provide scala-open-test
         scala-open-main
         scala-open-it
         scala-open-e2e
         scala-switch-main-test
         scala-switch-main-it
         scala-switch-main-e2e)

(require "clojure.scm")
(provide clojure-open-test
         clojure-open-main
         clojure-open-it
         clojure-open-e2e
         clojure-switch-main-test
         clojure-switch-main-it
         clojure-switch-main-e2e)

(require "felis.scm")
(provide felis-open
         file-browser
         file-browser-cwd)

;;@doc
;; Open a file browser in the root
(define (file-browser)
    (felis-file-browser felis-path broot-path))

;;@doc
;; Open a file browser in the parent directory of the current file
(define (file-browser-cwd)
    (felis-file-browser-cwd felis-path broot-path))

