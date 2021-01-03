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
    (should (not (counsel-edit-mode--validate-section-overlays)))
    (counsel-edit-mode--confirm-commit)
    (should (string=
             (counsel-edit-mode--test-file-string "A.txt")
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
    (should (not (counsel-edit-mode--validate-section-overlays)))
    (counsel-edit-mode--confirm-commit)
    (should (string= (counsel-edit-mode--test-file-string "multiline-match.txt")
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
    (should (not (counsel-edit-mode--validate-section-overlays)))
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
    (should (not (counsel-edit-mode--validate-section-overlays)))
    (counsel-edit-mode--confirm-commit)
    (should (string= (counsel-edit-mode--test-file-string "deletion.txt") "LINE 1
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
    (should (not (counsel-edit-mode--validate-section-overlays)))
    (counsel-edit-mode--confirm-commit)
    (should (string= (counsel-edit-mode--test-file-string "extra-context.txt") "REPLACED 1
LINE 2
LINE 3 TEST
REPLACED 4
INSERTION
LINE 5
"))))

(ert-deftest counsel-edit-mode-undo-line ()
  "Ensure that undo line works as expected"
  (setup-test-directory "assets/extra-context.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (let ((counsel-edit-mode-expand-braces-by-default nil))
      (switch-to-buffer (counsel-edit-mode-ivy-action)))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "LINE 3 TEST
"))
    (goto-char (point-min))
    (erase-buffer)
    (goto-char (point-max))
    (activate-mark)
    (goto-char (point-min))
    (counsel-edit-mode-undo-line)
    (should (not (counsel-edit-mode--validate-section-overlays)))
    (counsel-edit-mode--confirm-commit)
    (should (string= (counsel-edit-mode--test-file-string "extra-context.txt") "LINE 1
LINE 2
LINE 3 TEST
LINE 4
LINE 5
"))))

(ert-deftest counsel-edit-mode-goto ()
  "Ensure that goto works as expected"
  (setup-test-directory "assets/extra-context.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (let ((counsel-edit-mode-expand-braces-by-default nil))
      (switch-to-buffer (counsel-edit-mode-ivy-action)))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "LINE 3 TEST
"))
    (let ((buffer (window-buffer (counsel-edit-mode-goto))))
      (should (eq (current-buffer) buffer)))
    (should (string= (f-filename (buffer-file-name))
                     "extra-context.txt"))
    (should (eq (line-number-at-pos (point)) 3))))

(ert-deftest counsel-edit-mode-change-mode ()
  "Ensure that change mode works as expected"
  (setup-test-directory "assets/extra-context.txt")
  (let ((counsel--async-last-command (concat "grep -Rn " (shell-quote-argument "TEST" ) " " (shell-quote-argument test-directory))))
    (let ((counsel-edit-mode-expand-braces-by-default nil))
      (switch-to-buffer (counsel-edit-mode-ivy-action)))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (string= (buffer-string) "LINE 3 TEST
"))
    (counsel-edit-mode-change-major-mode 'emacs-lisp-mode)
    (should (string= (buffer-string) "LINE 3 TEST
"))
    (should (string-prefix-p  "*ag-edit" (buffer-name (current-buffer))))
    (should (eq major-mode 'emacs-lisp-mode))
    (should counsel-edit-mode--formatted-buffer)
    (should counsel-edit-mode--section-overlays)
    (should counsel-edit-mode--start-buffer)
    (should (not (counsel-edit-mode--validate-section-overlays)))))

(provide 'counsel-edit-mode-test)
