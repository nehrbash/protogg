;;; protogg.el --- project.el function remapping -*- lexical-binding: t -*-
;;
;; Copyright (C) 2023 by Stephe Nehrbass
;;
;; Author: nehrbash
;;
;; Keywords: convenience, minibuffer, protogg
;; Version: 0.1
;; Homepage: https://github.com/nehrbash/protogg
;;
;; This file is NOT part of GNU Emacs.
;;
;;; Commentary:
;;
;; Protogg remapps the `project.el' functions to their non-project related functions while also providing a minbuffer
;; keybind to switch between the two functions.
;;
;;; Code:

(require 'project)
(require 'delsel)

(defgroup protogg nil
  "Remap \=project\= keys to their regular counterpart."
  :group 'convenience
  :group 'minibuffer
  :link '(url-link :tag "GitHub" "https://github.com/nehrbash/protogg")
  :link '(emacs-library-link :tag "Library Source" "protogg.el")
  :prefix "protogg-")

(defcustom protogg-minibuffer-toggle-key "M-q"
  "Keybinding for switching protogg functions in the minibuffer ."
  :type 'key-sequence
  :group 'protogg)

(defvar protogg--toggle nil
  "Holds the state of protogg toggle.")

(defvar protogg--use-upper t
  "Holds the state of protogg function state.")

(defvar-keymap protogg-minibuffer-mode-map
  :doc "keybindings for toggling between interactive functions."
  protogg-minibuffer-toggle-key #'protogg-switch-minibuffer)

;;;###autoload
(defun protogg-switch-minibuffer ()
  "Toggle the state on wheather to use the project based function or not."
  (interactive)
  ;; toggle between using function1 and function2
  (if protogg--use-upper
      (setq protogg--use-upper nil)
    (setq protogg--use-upper t))
  (if (null (project-current))
      (error "not in project")
    (progn
      ;; yes I want to toggle
      (setq protogg--toggle t)
      (minibuffer-keyboard-quit))))

(define-minor-mode protogg-minibuffer-mode
  "Toggle between two interactive functions when they are active in the minibuffer."
  :init-value nil
  :group 'protogg
  :global nil
  :keymap protogg-minibuffer-mode-map)

(with-eval-after-load 'minibuffer
    (add-hook 'minibuffer-setup-hook #'protogg-minibuffer-mode))

(defmacro protogg-define (function1 function2 newfunc)
  "Create function NEWFUNC to toggle between FUNCTION1 and FUNCTION2.
It does this based on whether in a project and can be toggled with ."
  `(defun ,newfunc ()
     (interactive)
     ;; if protogg--toggle is true in a recursive call.
     (if protogg--toggle
         (setq protogg--toggle nil)
       ;; if not in a recursive call we need to reset to always default to function1
       (setq protogg--use-upper t))

     (if (and (project-current) protogg--use-upper)
         (condition-case nil
             (call-interactively ,function1 )
           (quit
            (if protogg--toggle
                (,newfunc))))
       (condition-case nil
           (call-interactively ,function2 )
         (quit
          (if protogg--toggle
              (,newfunc)))))))

;;;###autoload (autoload 'protogg-async-shell-command "protogg")
(protogg-define 'project-async-shell-command 'async-shell-command protogg-async-shell-command)
;;;###autoload (autoload 'protogg-compile "protogg")
(protogg-define 'project-compile 'compile protogg-compile)
;;;###autoload (autoload 'protogg-dired "protogg")
(protogg-define 'project-dired 'dired protogg-dired)
;;;###autoload (autoload 'protogg-eshell "protogg")
(protogg-define 'project-eshell 'eshell protogg-eshell)
;;;###autoload (autoload 'protogg-find-dired "protogg")
(protogg-define 'project-find-dir 'find-dired protogg-find-dired)
;;;###autoload (autoload 'protogg-find-file "protogg")
(protogg-define 'project-find-file 'find-file protogg-find-file)
;;;###autoload (autoload 'protogg-list-buffers "protogg")
(protogg-define 'project-list-buffers 'list-buffers protogg-list-buffers)
;;;###autoload (autoload 'protogg-shell "protogg")
(protogg-define 'project-shell 'shell protogg-shell)
;;;###autoload (autoload 'protogg-shell-command "protogg")
(protogg-define 'project-shell-command 'shell-command protogg-shell-command)
;;;###autoload (autoload 'protogg-switch-to-buffer "protogg")
(protogg-define 'project-switch-to-buffer 'switch-to-buffer protogg-switch-to-buffer)

(provide 'protogg)
;;; protogg.el ends here
