(require "utils.scm")

(provide scala-open-main
         scala-open-test
         scala-open-it
         scala-open-e2e
         scala-switch-main-test
         scala-switch-main-it
         scala-switch-main-e2e)

(define (test-suffix)
  (~> (maybe-get-env-var "SCALA_TEST_SUFFIX")
      (get-or-else "Test")))

(define (is-main file)
  (and (string-contains? file "src/main") 
       (not (ends-with? file (string-append (test-suffix) ".scala")))))

(define (is-test file)
  (and (string-contains? file "src/test")
       (ends-with? file (string-append (test-suffix) ".scala"))))

(define (scala-open-test-from-dir dir)
  (let ((test-file (~> (current-doc-path)
                       (string-replace "src/main" (string-append "src/" dir))
                       (trim-end-matches ".scala")
                       (string-append (test-suffix) ".scala"))))
       (focus-or-open test-file)))

;;@doc
;; Open the associated unit test file from src/test
(define (scala-open-test)
  (scala-open-test-from-dir "test"))

;;@doc
;; Open the associated integration test file from src/it
(define (scala-open-it)
  (scala-open-test-from-dir "it"))

;;@doc
;; Open the associated end-to-end test file from src/e2e
(define (scala-open-e2e)
  (scala-open-test-from-dir "e2e"))


;;@doc
;; Open the associated main file from src/main
(define (scala-open-main)
  (let ((main-file (~> (current-doc-path)
                       (string-replace "src/test" "src/main")
                       (trim-end-matches (string-append (test-suffix) ".scala"))
                       (string-append ".scala"))))
       (focus-or-open main-file)))

;;@doc
;; Switch betweent he  associated main and unit test file
(define (scala-switch-main-test)
  (if (is-main (current-doc-path)) 
      (scala-open-test)
      (scala-open-main)))

;;@doc
;; Switch betweent he  associated main and inetegration test file
(define (scala-switch-main-it)
  (if (is-main (current-doc-path)) 
      (scala-open-it)
      (scala-open-main)))

;;@doc
;; Switch betweent he  associated main and end-to-end test file
(define (scala-switch-main-e2e)
  (if (is-main (current-doc-path)) 
      (scala-open-e2e)
      (scala-open-main)))
