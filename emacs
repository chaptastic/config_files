(setq dotfiles-dir (expand-file-name "~/.emacs.d/"))
(add-to-list 'load-path dotfiles-dir)
;; (add-to-list 'load-path (concat dotfiles-dir "icicles"))

(add-to-list 'load-path "/usr/local/lib/erlang/lib/tools-2.6.4/emacs/")

(setq erlang-root-dir "/usr/local/lib/erlang/")
(add-to-list 'exec-path (concat erlang-root-dir "bin"))
(require 'erlang-start)

(setq mac-tool-bar-display-mode nil)
(tool-bar-mode nil)

(setq vc-follow-symlinks nil)

(fringe-mode 'default)

(setq custom-file (concat dotfiles-dir
			  "customizations" 
			  (int-to-string emacs-major-version) 
			  ".el"))
(load custom-file)

(global-set-key (kbd "A-/") 'comment-or-uncomment-region-or-line)
(define-key global-map (kbd "RET") 'newline-and-indent)

(require 'redo)



(setq viper-mode nil)
(defun setup-viper ()
  (require 'viper)

  ;; (setq vimpulse-experimental nil)
  (require 'vimpulse)

  (defadvice viper-maybe-checkout (around viper-svn-checkin-fix activate)
    "Advise viper-maybe-checkout to not do anything"
    nil
    )

  ;; List of keys found at
  ;; http://stackoverflow.com/questions/98225/vim-macros-dont-work
  (define-key viper-vi-global-user-map [(delete)] 'delete-char)
  (define-key viper-vi-global-user-map "/" 'isearch-forward-regexp)
  (define-key viper-vi-global-user-map "?" 'isearch-backward-regexp)
  (define-key viper-vi-global-user-map "\C-wh" 'windmove-left)
  (define-key viper-vi-global-user-map "\C-wj" 'windmove-down)
  (define-key viper-vi-global-user-map "\C-wk" 'windmove-up)
  (define-key viper-vi-global-user-map "\C-wl" 'windmove-right)
  (define-key viper-vi-global-user-map "\C-wv" '(lambda () (interactive)
						  (split-window-horizontally)
						  (other-window 1)
						  (switch-to-buffer (other-buffer))))
  (define-key viper-vi-global-user-map "n" 'aquamacs-repeat-isearch)

  ;; (define-key viper-visual-mode-map "F" 'viper-find-char-backward)
  ;; (define-key viper-visual-mode-map "t" 'viper-goto-char-forward)
  ;; (define-key viper-visual-mode-map "T" 'viper-goto-char-backward)
  ;; (define-key viper-visual-mode-map "e" '(lambda ()
  ;;                                          (interactive)
  ;;                                          (viper-end-of-word 1)
  ;;                                          (viper-forward-char 1)))

  (push '("only" (delete-other-windows)) ex-token-alist)
  (push '("close" (delete-window)) ex-token-alist)

  ;; Make ,be open the buffer menu
  (define-key viper-vi-global-user-map ",be" 'buffer-menu)
  (define-key viper-vi-global-user-map "\C-a" 'viper-bol-and-skip-white)
  (define-key viper-vi-global-user-map "\C-e" 'viper-goto-eol)

)

(if viper-mode
    (setup-viper))

(setq set-region-to-isearch-match nil)

;; Support for marking a rectangle of text with highlighting.
(require 'rect-mark)
(define-key ctl-x-map "r\C-@" 'rm-set-mark)
(define-key ctl-x-map [?r ?\C-\ ] 'rm-set-mark)
(define-key ctl-x-map "r\C-x" 'rm-exchange-point-and-mark)
(define-key ctl-x-map "r\C-w" 'rm-kill-region)
(define-key ctl-x-map "r\M-w" 'rm-kill-ring-save)
(define-key global-map [S-down-mouse-1] 'rm-mouse-drag-region)
(autoload 'rm-set-mark "rect-mark"
  "Set mark for rectangle." t)
(autoload 'rm-exchange-point-and-mark "rect-mark"
  "Exchange point and mark for rectangle." t)
(autoload 'rm-kill-region "rect-mark"
  "Kill a rectangular region and save it in the kill ring." t)
(autoload 'rm-kill-ring-save "rect-mark"
  "Copy a rectangular region to the kill ring." t)
(autoload 'rm-mouse-drag-region "rect-mark"
  "Drag out a rectangular region with the mouse." t)

(global-font-lock-mode t)

;; (require 'zenburn)
;; (unless (zenburn-format-spec-works-p)
;;   (zenburn-define-format-spec))
;; (color-theme-zenburn)

;; (require 'color-theme)
;; (setq color-theme-is-global t)
;; (color-theme-initialize)
;; (color-theme-gtk-ide) ;; lt *
;;(color-theme-charcoal-black) ;;* 

(set-face-font 'default
               "-apple-consolas-medium-r-normal--12-0-72-72-m-0-iso10646-1")

(require 'fuzzy-match)

(require 'ido)
(ido-mode t)

;; (load-library "icicles")
;; (icy-mode t)

;; Ruby setup

(add-to-list 'load-path (concat dotfiles-dir "emacs-rails"))
(require 'rails)

;(add-to-list 'load-path "~/.emacs.d/rinari")
;(require 'rinari)

(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))

;; Use j/k for down/up in buffer menu
(define-key Buffer-menu-mode-map "j" 'visual-line-down)
(define-key Buffer-menu-mode-map "k" 'visual-line-up)

;;(require 'project-setup)
(load-file (concat dotfiles-dir "cedet-1.0pre6/common/cedet.el"))
(global-ede-mode 1)                 ; Enable the Project management system
(semantic-load-enable-code-helpers) ; Enable prototype help and smart completion 
(global-srecode-minor-mode 1)       ; Enable template insertion menu

(add-to-list 'load-path (concat dotfiles-dir "ecb-2.40"))
(require 'ecb)

;; Work around a bug on OS X where system-name is FQDN
(if (eq system-type 'darwin)
    (setq system-name (car (split-string system-name "\\."))))

(setq system-specific-config (concat dotfiles-dir system-name ".el")
      user-specific-config (concat dotfiles-dir user-login-name ".el")
      user-specific-dir (concat dotfiles-dir user-login-name))
(add-to-list 'load-path user-specific-dir)

(if (file-exists-p system-specific-config) (load system-specific-config))
(if (file-exists-p user-specific-config) (load user-specific-config))
(if (file-exists-p user-specific-dir)
  (mapc #'load (directory-files user-specific-dir nil ".*el$")))

(server-start)