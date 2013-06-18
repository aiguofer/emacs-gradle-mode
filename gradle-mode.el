;;; gradle-mode.el --- gradle integration with Emacs

;; This is free and unencumbered software released into the public domain.

;;; Install:

;; Put this file somewhere on your load path (like in .emacs.d), and
;; require it. That's it!

;;    (require 'gradle-mode)

;;; Code:
(require 'compile)

(defun gradle-executable-path ()
  (executable-find "gradle"))

(defun gradle-input-tasks ()
  (list (read-string "Enter your gradle tasks to execute (and/or) options: ")))

(defun gradle-find-project-dir ()
  (with-temp-buffer
    (while (and (not (file-exists-p "build.gradle"))
		(not (equal "/" default-directory)))
      (cd ".."))
  default-directory))

(defun gradle-execute-interactive (tasks)
  (interactive (list (gradle-input-tasks)))
  (gradle-execute tasks))

(defun gradle-execute-daemon-interactive (tasks)
  (interactive (list (gradle-input-tasks)))
  (gradle-execute (append tasks '("--daemon"))))

(defun gradle-execute (tasks)
  (let ((default-directory (gradle-find-project-dir)))
   (compile (gradle-make-command tasks))))

(defun gradle-make-command (tasks)
  (concat (gradle-executable-path)
	  (when tasks (mapconcat 'identity (cons "" tasks) " "))))

(defvar gradle-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-g b") (lambda () (interactive) (gradle-execute '("build"))))
    (define-key map (kbd "C-c C-g t") (lambda () (interactive) (gradle-execute '("test"))))
    (define-key map (kbd "C-c C-g C-d b") (lambda () (interactive) (gradle-execute '("build" "--daemon"))))
    (define-key map (kbd "C-c C-g C-d t") (lambda () (interactive) (gradle-execute '("test"  "--daemon"))))
    (define-key map (kbd "C-c C-g d") 'gradle-execute-daemon-interactive)
    (define-key map (kbd "C-c C-g r") 'gradle-execute-interactive)
    map)
  "Keymap for the gradle minor mode.")

;;;###autoload
(define-minor-mode gradle-mode
  "Gradle Mode -- run gradle from any buffer, will scan up for nearest gradle build file in a directory and run the command."
  :lighter " gra"
  :keymap 'gradle-mode-map
  :global t)

(provide 'gradle-mode)

;; gradle-mode.el ends here
