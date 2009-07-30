(setq load-path (cons (expand-file-name "~/.emacs.d") load-path))
(setq load-path (cons (expand-file-name "~/.emacs.d/icicles") load-path))

(setq mac-tool-bar-display-mode nil)
(tool-bar-mode nil)

(fringe-mode 'default)

(setq custom-file "~/.emacs.d/customizations.el")
(load custom-file)

(global-set-key (kbd "A-/")
                'comment-or-uncomment-region-or-line)

(setq viper-mode t)
(require 'viper)

(setq vimpulse-experimental nil)
(require 'vimpulse)

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

(require 'zenburn)
(unless (zenburn-format-spec-works-p)
  (zenburn-define-format-spec))
(color-theme-zenburn)

(set-face-font 'default
               "-apple-consolas-medium-r-normal--12-0-72-72-m-0-iso10646-1")

;; (require 'ido)
;; (ido-mode t)

(load-library "icicles")
(icy-mode t)

;; Ruby setup

(add-to-list 'load-path "~/.emacs.d/rinari")
(require 'rinari)

(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))

;; Make ,be open the buffer menu
(define-key viper-vi-global-user-map ",be" 'buffer-menu)
(define-key viper-vi-global-user-map "C-a" 'beginning-of-visual-line)
(define-key viper-vi-global-user-map "C-e" 'end-of-visual-line)
