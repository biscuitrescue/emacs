(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
			      :ref nil :depth 1 :inherit ignore
			      :files (:defaults "elpaca-test.el" (:exclude "extensions"))
			      :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install a package via the elpaca macro
;; See the "recipes" section of the manual for more details.

;; (elpaca example-package)

;; Install a package via the elpaca macro
;; See the "recipes" section of the manual for more details.

;; (elpaca example-package)

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;;When installing a package used in the init file itself,
;;e.g. a package which adds a use-package key word,
;;use the :wait recipe keyword to block until that package is installed/configured.
;;For example:
;;(use-package general :ensure (:wait t) :demand t)

(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-vsplit-window-right t
        evil-split-window-below t)
  :config
  (evil-set-undo-system 'undo-redo)
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(use-package evil-tutor
  :ensure t
  :after evil)

(use-package which-key
  :ensure t
  :config
  (which-key-mode 1)
  (setq which-key-side-window-location 'bottom
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.5
        which-key-idle-secondary-delay 0.05
        which-key-max-description-length 30
        which-key-add-column-padding 1
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-separator " → "
        which-key-allow-imprecise-window-fit t))

(use-package general
  :ensure t
  :config
  (general-evil-setup)
  (general-create-definer cafo/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")

  ;; Files
  (cafo/leader-keys
    "." '(find-file :wk "Find file")
    "f" '(:ignore t :wk "Files")
    "f s" '(save-buffer :wk "Save buff")
    "f c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
    "w" '(evil-window-map :wk "Window"))

  ;; Code
  (cafo/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe variable")
    "h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config")
    "TAB TAB" '(comment-line :wk "Comment Lines"))

  ;; Buffers
  (cafo/leader-keys
    "b" '(:ignore t :wk "buffer")
    "b b" '(switch-to-buffer :wk "Switch Buffer")
    "b i" '(ibuffer :wk "IBuffer")
    "b c" '(kill-this-buffer :wk "Kill this Buffer")
    "b n" '(next-buffer :wk "Next Buffer")
    "b p" '(previous-buffer :wk "Prev Buffer")
    "b r" '(revert-buffer :wk "Reload Buffer"))
  )

(use-package hydra
  :ensure t
  :config
  ;; Window resize hydra
  (defhydra hydra-window-resize (:hint nil)
    "
Resize window:
_h_: ←  _l_: →  _j_: ↓  _k_: ↑
_q_: quit
"
    ("h" enlarge-window-horizontally)
    ("l" shrink-window-horizontally)
    ("j" shrink-window)
    ("k" enlarge-window)
    ("q" nil "quit"))

  ;; Bind hydra to leader key: SPC w r
  (cafo/leader-keys
    "w r" '(hydra-window-resize/body :which-key "Resize Window")))

(set-face-attribute 'default nil
   		    :font "Zed Mono"
   		    :height 150
   		    :weight 'medium)
(set-face-attribute 'variable-pitch nil
   		    :font "Zed Mono"
   		    :height 150
   		    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
   		    :font "Zed Mono"
   		    :height 150;
   		    :weight 'medium)
(set-face-attribute 'font-lock-comment-face nil
   		    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
   		    :slant 'italic)

;; (add-to-list 'default-frame-alist '(font . "Fira Code-13))
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-startup-banner 'logo)
  ;; (setq dashboard-center-content t)
  ;; (setq dashboard-vertically-center-content t)
  (setq dashboard-show-shortcuts nil)
  ;; (setq dashboard-items '((recents   . 5)
  ;;                         (bookmarks . 3)
  ;;                         (projects  . 3)
  ;;                         (agenda    . 5)
  ;;                         (registers . 3)))

  (dashboard-setup-startup-hook))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(load-theme 'black t)

(use-package toc-org
  :ensure t
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(require 'org-tempo)

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets :ensure t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(setq electric-indent -1)

(use-package diminish
  :ensure t)

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

(use-package corfu
  :ensure t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.0)
  (corfu-quit-at-boundary 'separator)
  (corfu-echo-documentation 0.25)
  (corfu-preview-current 'insert)
  (corfu-preselect-first nil)

  :bind (:map corfu-map
	      ("M-SPC" . corfu-insert-separator)
	      ("RET" . corfu-insert)
	      ("TAB" . corfu-next)
	      ("S-TAB" . corfu-previous)
	      ([tab] . corfu-next)
	      ([backtab] . corfu-previous)
	      ("S-<return>" . corfu-insert))
  
  :init
  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)

  (corfu-history-mode))

;; Enable Vertico.
(use-package vertico
  :ensure t
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 20) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.

(use-package projectile
  :ensure t
  :config
  (projectile-mode 1))

(use-package emacs
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)

  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

(use-package vterm
  :ensure t)
(setq shell-file-name "/run/current-system/sw/bin/fish"
      vterm-max-scrollback 5000)

(use-package vterm-toggle
  :after vterm
  :ensure t
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project))
