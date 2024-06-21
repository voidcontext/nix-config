(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))
(require "helix/editor.scm")

(provide open-helix-scm scala-open-test scala-switch-main-test)

;;@doc
;; Open the helix.scm file
(define (open-helix-scm)
  (helix.open (helix.static.get-helix-scm-path)))

;; Generic
(define (insert-string-at-selection str)
  (helix.static.insert_string str)
  (helix.static.insert_mode))

(define (debug v)
  (insert-string-at-selection (to-string v))
  v)

;; Only get the doc if it exists
(define (editor-get-doc-if-exists doc-id)
  (if (editor-doc-exists? doc-id) (editor->get-document doc-id) #f))

(define (doc-path doc-id)
  (let ((document (editor-get-doc-if-exists doc-id)))
    (if document (Document-path document) #f)))

(define (current-path)
  (let* ([focus (editor-focus)]
         [focus-doc-id (editor->doc-id focus)])

    (doc-path focus-doc-id)))

(define (find pred ls)
  (cond ((empty? ls) #f)
        ((pred (car ls)) (car ls))
        (else (find pred (cdr ls)))))

(define (find-doc path)
  (find (lambda (doc-id) (equal? (doc-path doc-id) path)) 
                         (editor-all-documents)))

(define (focus-or-open path)
  (let ((doc-id (find-doc path)))
    (if doc-id 
        (let ((view-id (~> (editor-doc-in-view? doc-id)
                             (get-or-else #f))))
            (if view-id (editor-set-focus! view-id)
                        (editor-switch-action! doc-id (Action/Replace))))
        (helix.open path))))

;; Scala stuff

(define (get-or-else option default)
  (cond ((Some? option) (Some->value option)) 
        ((Ok? option) (Ok->value option))
        (else default)))

(define (test-suffix)
    (~> (maybe-get-env-var "SCALA_TEST_SUFFIX")
        (get-or-else "Test")))

(define (is-main file)
  (and (string-contains? file "src/main") (not (ends-with? file (string-append (test-suffix) ".scala")))))

(define (is-test file)
  (and (string-contains? file "src/test") (ends-with? file (string-append (test-suffix) ".scala"))))


(define (scala-open-test)
  (let ((test-file (~> (current-path)
                       (string-replace "src/main" "src/test")
                       (trim-end-matches ".scala")
                       (string-append (test-suffix) ".scala"))))
       (focus-or-open test-file)))

(define (scala-open-main)
  (let ((main-file (~> (current-path)
                       (string-replace "src/test" "src/main")
                       (trim-end-matches (string-append (test-suffix) ".scala"))
                       (string-append ".scala"))))
       (focus-or-open main-file)))

(define (scala-switch-main-test)
  (if (is-main (current-path)) 
      (scala-open-test)
      (scala-open-main)))
