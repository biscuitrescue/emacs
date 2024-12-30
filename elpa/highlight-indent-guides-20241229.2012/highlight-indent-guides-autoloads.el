;;; highlight-indent-guides-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from highlight-indent-guides.el

(autoload 'highlight-indent-guides-mode "highlight-indent-guides" "\
Display indent guides in a buffer.

This is a minor mode.  If called interactively, toggle the
`Highlight-Indent-Guides mode' mode.  If the prefix argument is
positive, enable the mode, and if it is zero or negative, disable
the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `highlight-indent-guides-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(autoload 'highlight-indent-guides-auto-set-faces "highlight-indent-guides" "\
Automatically calculate indent guide faces.
If this feature is enabled, calculate reasonable values for the indent guide
colors based on the current theme's colorscheme, and set them appropriately.
This runs whenever a theme is loaded, but it can also be run interactively.

(fn &rest _)" t)
(register-definition-prefixes "highlight-indent-guides" '("highlight-indent-guides-"))

;;; End of scraped data

(provide 'highlight-indent-guides-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; highlight-indent-guides-autoloads.el ends here
