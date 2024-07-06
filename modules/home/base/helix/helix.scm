(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))
(require "helix/editor.scm")


(provide open-helix-scm )
;;@doc
;; Open the helix.scm file
(define (open-helix-scm)
  (helix.open (helix.static.get-helix-scm-path)))

;; Modules

(require "scala.scm")
(provide scala-open-test
         scala-open-main
         scala-switch-main-test)
