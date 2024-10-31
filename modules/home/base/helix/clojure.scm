(require "utils.scm")

(provide clojure-open-main
         clojure-open-test
         clojure-open-it
         clojure-open-e2e
         clojure-switch-main-test
         clojure-switch-main-it
         clojure-switch-main-e2e)

(define test-suffix "_test")

(define (is-main file)
  (and (string-contains? file "src/") 
       (not (ends-with? file (string-append test-suffix ".clj")))))

(define (is-test file)
  (and (string-contains? file "test/")
       (ends-with? file (string-append test-suffix ".clj"))))

(define (to-test-path path suite)
  (cons "test" (cons (first path) (cons suite (rest path)))))

(define (to-rel-path path)
  (trim-start-matches path (current-directory)))

(define (clojure-open-test-from-main suite)
  (let ((test-file (~> (to-rel-path (current-doc-path))
                       (split-many "/")
                       (rest)
                       (rest)
                       (to-test-path suite)
                       (string-join "/")
                       (trim-end-matches ".clj")
                       (string-append test-suffix ".clj"))))
       (focus-or-open (string-append (current-directory) "/" test-file))))

;;@doc
;; Open the associated unit test file from src/test
(define (clojure-open-test)
  (clojure-open-test-from-main "unit"))

;;@doc
;; Open the associated integration test file from src/it
(define (clojure-open-it)
  (clojure-open-test-from-main "it"))

;;@doc
;; Open the associated end-to-end test file from src/e2e
(define (clojure-open-e2e)
  (clojure-open-test-from-main "e2e"))

(define (to-main-path path)
  (cons "src" (cons (first path) (rest (rest path)))))

;;@doc
;; Open the associated main file from src/main
(define (clojure-open-main)
  (let ((main-file (~> (to-rel-path (current-doc-path))
                       (split-many "/")
                       (rest)
                       (rest)
                       (to-main-path)
                       (string-join "/")
                       (trim-end-matches (string-append test-suffix ".clj"))
                       (string-append ".clj"))))
       (focus-or-open main-file)))

;;@doc
;; Switch between the  associated main and unit test file
(define (clojure-switch-main-test)
  (if (is-main (current-doc-path)) 
      (clojure-open-test)
      (clojure-open-main)))

;;@doc
;; Switch between the  associated main and inetegration test file
(define (clojure-switch-main-it)
  (if (is-main (current-doc-path)) 
      (clojure-open-it)
      (clojure-open-main)))

;;@doc
;; Switch betweent the  associated main and end-to-end test file
(define (clojure-switch-main-e2e)
  (if (is-main (current-doc-path)) 
      (clojure-open-e2e)
      (clojure-open-main)))
