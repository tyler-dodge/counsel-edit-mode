;;; -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'org)
(require 'el-mock)

(when (require 'undercover nil t)
  (undercover "*.el"))
(require 'counsel-edit-mode (expand-file-name "counsel-edit-mode.el"))

(ert-deftest counsel-edit-mode-exists ()
  "Making sure expected symbols are exported."
  (should (fboundp 'counsel-edit-mode-setup-ivy)))

(ert-deftest counsel-edit-mode-simple-substitution ()
  "Ensure that substituting works as expected"
  (setup-test-directory "assets/A.txt" "assets/B.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (switch-to-buffer (counsel-edit-mode-ivy-action))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "TEST one
"))

    (goto-char (point-min))
    (delete-char 4)
    (insert "REPLACED")
    (counsel-edit-mode--confirm-commit)
    (should (string=
             (with-current-buffer (find-file-noselect (f-join test-directory "A.txt"))
               (buffer-string))
             "REPLACED one
two
three
four
five
six
"))))

(ert-deftest counsel-edit-mode-multiline-substitution ()
  "Ensure that multiline substituting works as expected"
  (setup-test-directory "assets/multiline-match.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (switch-to-buffer (counsel-edit-mode-ivy-action))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "TEST one
two TEST three
four five TEST
"))

    (goto-char (point-min))
    (while (re-search-forward (rx "TEST") nil t)
      (replace-match "REPLACED"))
    (counsel-edit-mode--confirm-commit)
    (should (string=
             (with-current-buffer (find-file-noselect (f-join test-directory "multiline-match.txt"))
               (buffer-string))
             "REPLACED one
SPACE
two REPLACED three
SPACE
four five REPLACED
"))))

(ert-deftest counsel-edit-mode-paren-expansion ()
  "Ensure that multiline substituting works as expected"
  (setup-test-directory "assets/paren-expansion.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (let ((counsel-edit-mode-expand-braces-by-default nil))
      (switch-to-buffer (counsel-edit-mode-ivy-action)))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "    TEST (
"))
    (counsel-edit-mode-expand-all)
    (should (string= (buffer-string) "(defun
    TEST (
      should-expand))
"))))

(ert-deftest counsel-edit-mode-deletion ()
  "Ensure that deletion works as expected"
  (setup-test-directory "assets/deletion.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (let ((counsel-edit-mode-expand-braces-by-default nil))
      (switch-to-buffer (counsel-edit-mode-ivy-action)))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "TEST LINE 3
"))
    (goto-char (point-min))
    (counsel-edit-mode-mark-line-deleted)
    (counsel-edit-mode--confirm-commit)
    (should (string= (with-current-buffer (find-file-noselect (f-join test-directory "deletion.txt")) (buffer-string)) "LINE 1
LINE 2
LINE 4
LINE 5
"))))

(ert-deftest counsel-edit-mode-extra-context ()
  "Ensure that context expansion works as expected"
  (setup-test-directory "assets/extra-context.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (let ((counsel-edit-mode-expand-braces-by-default nil))
      (switch-to-buffer (counsel-edit-mode-ivy-action)))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "LINE 3 TEST
"))
    (goto-char (point-min))
    (counsel-edit-mode-expand-context-down nil)
    (counsel-edit-mode-expand-context-up nil)
    (counsel-edit-mode-expand-context-up nil)
    (goto-char (point-min))
    (re-search-forward (rx "LINE 1"))
    (replace-match "REPLACED 1")
    (re-search-forward (rx "LINE 4"))
    (replace-match "REPLACED 4")
    (goto-char (point-max))
    (insert "INSERTION")
    (counsel-edit-mode--confirm-commit)
    (should (string= (with-current-buffer (find-file-noselect (f-join test-directory "extra-context.txt")) (buffer-string)) "REPLACED 1
LINE 2
LINE 3 TEST
REPLACED 4
INSERTION
LINE 5
"))))

(provide 'counsel-edit-mode-test)