(require "utils.scm")

(provide scala-open-main
         scala-open-test
         scala-switch-main-test)

(define (test-suffix)
    (~> (maybe-get-env-var "SCALA_TEST_SUFFIX")
        (get-or-else "Test")))

(define (is-main file)
  (and (string-contains? file "src/main") (not (ends-with? file (string-append (test-suffix) ".scala")))))

(define (is-test file)
  (and (string-contains? file "src/test") (ends-with? file (string-append (test-suffix) ".scala"))))

;;@doc
;; Open the associated test file from src/test
(define (scala-open-test)
  (let ((test-file (~> (current-path)
                       (string-replace "src/main" "src/test")
                       (trim-end-matches ".scala")
                       (string-append (test-suffix) ".scala"))))
       (focus-or-open test-file)))

;;@doc
;; Open the associated main file from src/main
(define (scala-open-main)
  (let ((main-file (~> (current-path)
                       (string-replace "src/test" "src/main")
                       (trim-end-matches (string-append (test-suffix) ".scala"))
                       (string-append ".scala"))))
       (focus-or-open main-file)))

;;@doc
;; Switch betweent he  associated main and test file
(define (scala-switch-main-test)
  (if (is-main (current-path)) 
      (scala-open-test)
      (scala-open-main)))
