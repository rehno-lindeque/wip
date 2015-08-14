


(require 'package) ;; You might already have this line

(package-initialize) ;; You might already have this line


;; (require 'tramp) 
;; (add-to-list 'tramp-remote-path "/run/current-system/sw/bin")
;; 
;; (require 'god-mode)


;; (setq load-path
;;  (cons "/run/current-system/sw/share/emacs/site-lisp"
;;    load-path))

;; (setq load-path
;;   (cons (concat (getenv "HOME") "/.nix-profile/share/emacs/site-lisp")
;;     load-path))

(require 'nix-mode)

(require 'evil)
(evil-mode 1)

;; (require 'god-mode)
;; (god-mode)


;; customize evil-god-state
(require 'evil-god-state)
(evil-god-state)

(evil-define-key 'normal global-map "," 'evil-execute-in-god-state) ;; enter god state

;; (add-hook 'evil-god-state-entry-hook (lambda () (diminish 'god-local-mode)
;; (add-hook 'evil-god-state-exit-hook (lambda () (diminish-undo 'god-local-mode)))

(evil-define-key 'god global-map [escape] 'evil-god-state-bail) ;; abort god command

;; evil state (vim mode) colors - status line 
(lexical-let ((default-color (cons (face-background 'mode-line)
				   (face-foreground 'mode-line))))
  (add-hook 'post-command-hook
    (lambda ()
      (let ((color (cond ((minibufferp) default-color)
			 ((evil-insert-state-p) '("#e80000" . "#ffffff"))
			 ((evil-emacs-state-p)  '("#444488" . "#ffffff"))
			 ((buffer-modified-p)   '("#006fa0" . "#ffffff"))
			 ((evil-god-state-p)    '("#006fa0" . "#ffffff"))
			 (t default-color))))
	(set-face-background 'mode-line (car color))
	(set-face-foreground 'mode-line (cdr color))))))



;; evil state (vim mode) colors - background
;; (add-hook 'post-command-hook
  ;; (lambda ()
    ;; (let ((color (cond ((minibufferp) default-color)
		       ;; ((evil-insert-state-p) '("#e80000" . "#ffffff"))
		       ;; ((evil-emacs-state-p)  '("#444488" . "#ffffff"))
		       ;; ((buffer-modified-p)   '("#006fa0" . "#ffffff"))
		       ;; (t default-color))))
      ;; (set-background-color (car color)))))

(add-hook 'post-command-hook
  (lambda ()
    (set-background-color 
      (cond ((minibufferp) "#382c38")
	    ((evil-insert-state-p) "#222")
	    ((evil-visual-state-p) "#303830")
	    ((evil-emacs-state-p)  "#445")
	    ((evil-god-state-p)    "#334")
            (t "#382c38")))))

;; theme
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes (quote (monokai)))
 '(custom-safe-themes
   (quote
    ("436ae3105bb26b7e3edbd624612ee3ba929fd568d3b3bd1f72e6aa2b0cab1bb7" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
