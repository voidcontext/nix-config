(defun sbt-do-compile ()
  "Compile all sources including tests."
  (interactive)
  (sbt:command "test:compile"))

(defun sbt-do-run ()
  "Execute the sbt `run' command for the project."
  (interactive)
  (sbt:command "run"))

(defun sbt-do-test ()
  "Run all the tests."
  (interactive)
  (sbt-command "test"))

(defun sbt-do-it-test ()
  "Run all the integration tests."
  (interactive)
  (sbt-command "it:test"))

(defun scala-file-in-current-buffer()
  "Return the name of the scala file in the current buffer"
  (replace-regexp-in-string "\\.scala\\(<.*>\\)?$" "" (buffer-name (window-buffer (minibuffer-selected-window)))))

(defun scala-test-file()
  "Returns the spec file of the current file"
  (let ((ffile (scala-file-in-current-buffer)))
    (if (string-match "Spec$" ffile) ffile (concat ffile "Spec"))))

(defun sbt-do-it-test-for-buffer()
  "Run test for buffer"
  (interactive)
  (sbt-command (concat "it:testOnly" " " "*" (scala-test-file))))

(defun sbt-do-clean ()
  "Execute the sbt `clean' command for the project."
  (interactive)
  (sbt:command "clean"))

(defun sbt-do-package ()
  "Build a jar file of the project."
  (interactive)
  (sbt:command "package"))

(use-package sbt-mode
  :commands
  sbt-start
  sbt-command
  :bind
  (:map sbt:mode-map ("C-a" . comint-bol)))

(use-package scala-mode
  :config
  (subword-mode +1)
  ;(which-key-declare-prefixes-for-mode 'scala-mode "C-c m" "scala")
  :bind
  ("C-c m b" . sbt-hydra)
  ("C-c m c" . sbt-do-compile)
  ("C-c m t" . sbt-do-test)
  ("C-c m i" . sbt-do-it-test)
  ("C-c t i" . sbt-do-it-test-for-buffer))