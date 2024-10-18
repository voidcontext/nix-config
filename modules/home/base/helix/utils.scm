(require (prefix-in helix.static. "helix/static.scm"))
(require (prefix-in helix. "helix/commands.scm"))

(require "helix/editor.scm")

(provide get-or-else
         current-doc-path
         focus-or-open)


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

(define (current-doc-path)
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
        (let ((view-id (editor-doc-in-view? doc-id)))
            (if view-id (editor-set-focus! view-id)
                        (editor-switch-action! doc-id (Action/Replace))))
        (helix.open path))))

;; Scala stuff

(define (get-or-else option default)
  (cond ((Some? option) (Some->value option)) 
        ((Ok? option) (Ok->value option))
        (else default)))
