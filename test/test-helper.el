;;; -*- lexical-binding: t -*-
(defvar test-directory nil)
(defun setup-test-directory (&rest file-list)
  (unless (and (s-ends-with-p "test/" default-directory)
               (f-exists-p "test"))
    (setq default-directory (f-join default-directory "test")))
  (setq test-directory (f-join default-directory "../build/test-files"))
  (mkdir test-directory t)
  (f-delete test-directory t)
  (mkdir test-directory t)
  (cl-loop for file in file-list
           do
           (copy-file file (f-join test-directory (f-filename file))))
  (switch-to-buffer (generate-new-buffer " *test-buffer*")))

(defun counsel-edit-mode--test-file-string (file-name)
  (with-temp-buffer (insert-file-contents (f-join test-directory file-name)) (buffer-string)))

