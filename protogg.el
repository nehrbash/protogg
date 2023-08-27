;;; protogg.el --- project.el function remapping -*- lexical-binding: t -*-

;;; Commentary:

;; Protogg remapps the `project.el' functions to their non-project related functions while also providing a minbuffer
;; keybind to switch between the two functions.

;;; Code:

(require 'project)
(require 'delsel)

(defgroup protogg nil
  "Remap \=project\= keys to their regular counterpart."
  :group 'convenience
  :group 'minibuffer
  :link '(url-link :tag "GitHub" "<fill this in later>")
  :link '(emacs-library-link :tag "Library Source" "protogg.el")
  :prefix "protogg-")

;; (defcustom protogg-toggle-key nil
;;   "Keybind for toggling between project and non-project functions.
;; The key must be a string accepted by `key-valid-p'."
;;   :type '(choice key (const nil)))

;; (defvar protogg-toggle--key "M-q"
;;   "Keybind for toggling between project and non-project functions.
;; The key must be a string accepted by `key-valid-p'."
;;   )

(defvar protogg--toggle nil
  "Holds the state of protogg toggle.")

(defvar protogg--use-upper t
  "Holds the state of protogg function state.")

(defvar-keymap protogg-minibuffer-mode-map
  :doc "Keymap used for switching protogg functions."
  "M-q" #'protogg-switch-minibuffer)

(defun protogg-switch-minibuffer ()
  "Toggle the state on wheather to use the project based function or not."
  (interactive)
  (if protogg--use-upper
    (setq protogg--use-upper nil)
    (setq protogg--use-upper t))
  (setq protogg--toggle t)
  (if (null (project-current))
    (message "Not in project.")
    (minibuffer-keyboard-quit)))

(defun protogg-switch-minibuffer-hook ()
  "Call the next function after quitting minbuffer."
  (protogg-minibuffer-mode -1))


(define-minor-mode protogg-minibuffer-mode
  "Toggle between two interactive functions when they are active in the minibuffer."
  :init-value nil
  :group 'protogg
  :global nil
  :keymap protogg-minibuffer-mode-map)

(with-eval-after-load 'minibuffer
  (add-hook 'minibuffer-setup-hook #'protogg-minibuffer-mode)
  (add-hook 'minibuffer-exit-hook #'protogg-switch-minibuffer-hook))

(defmacro protogg-create (function1 function2 newfunc)
  "Create function NEWFUNC to toggle between FUNCTION1 and FUNCTION2.
It does this based on whether in a project and can be toggled with ."
  `(defun ,newfunc ()
     (interactive)
     (if protogg--toggle
       (setq protogg--toggle nil)
       (setq protogg--use-upper t))
     (if (and (project-current) protogg--use-upper)
       (condition-case nil
         (call-interactively ',function1)
         (quit
           (if protogg--toggle
             (progn
               (call-interactively #',newfunc)
               (minibuffer-keyboard-quit))))))
     (if (null protogg--use-upper)
       (condition-case nil
         (call-interactively ',function2)
         (quit
           (if protogg--toggle
             (progn
               (call-interactively #',newfunc)
               (minibuffer-keyboard-quit)))))
       (call-interactively ',function2))))



;;; define buffer mode and keymap
(defvar-keymap protogg-mode-map
  :doc "Keymap used for switching protogg functions.")

(define-minor-mode protogg-mode
  "Toggle between two interactive functions when they are active in the minibuffer."
  :lighter "protogg"
  :init-value nil
  :global t
  :group 'protogg
  :keymap protogg-mode-map)


(define-key protogg-mode-map [remap async-shell-command] 'protogg-async-shell-command)
(define-key protogg-mode-map [remap compile] 'protogg-compile)
(define-key protogg-mode-map [remap dired] 'protogg-dired)
(define-key protogg-mode-map [remap display-buffer] 'protogg-display-buffer)
(define-key protogg-mode-map [remap eshell] 'protogg-eshell)
(define-key protogg-mode-map [remap find-dired] 'protogg-find-dired)
(define-key protogg-mode-map [remap find-file] 'protogg-find-file)
(define-key protogg-mode-map [remap kill-buffer] 'protogg-kill-buffer)
(define-key protogg-mode-map [remap list-buffers] 'protogg-list-buffers)
(define-key protogg-mode-map [remap shell-command] 'protogg-shell-command)
(define-key protogg-mode-map [remap shell] 'protogg-shell)
(define-key protogg-mode-map [remap switch-to-buffer] 'protogg-switch-to-buffer)
(protogg-create project-async-shell-command async-shell-command protogg-async-shell-command)
(protogg-create project-compile compile protogg-compile)
(protogg-create project-dired dired protogg-dired)
(protogg-create project-display-buffer display-buffer protogg-display-buffer)
(protogg-create project-eshell eshell protogg-eshell)
(protogg-create project-find-dir find-dired protogg-find-dired)
(protogg-create project-find-file find-file protogg-find-file)
(protogg-create project-kill-buffer kill-buffer protogg-kill-buffer)
(protogg-create project-list-buffers list-buffers protogg-list-buffers)
(protogg-create project-shell shell protogg-shell)
(protogg-create project-shell-command shell-command protogg-shell-command)
(protogg-create project-switch-to-buffer switch-to-buffer protogg-switch-to-buffer)

;; use projectile for vterm.

;; (defun projectile--vterm (&optional new-process other-window)
;;   "Invoke `vterm' in the project's root.

;; Use argument NEW-PROCESS to indicate creation of a new process instead.
;; Use argument OTHER-WINDOW to indentation whether the buffer should
;; be displayed in a different window.

;; Switch to the project specific term buffer if it already exists."
;;   (let (project (projectile-acquire-root))
;;     (unless (require 'vterm nil 'noerror)
;;       (error "Package 'vterm' is not available"))
;;       (projectile-with-default-dir project
;;         (if other-window
;;             (vterm-other-window buffer)
;;           (vterm buffer))))
;;     (switch-to-buffer buffer)))


(provide 'protogg)
;;; protogg.el ends here
