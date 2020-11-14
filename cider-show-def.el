;;; cider-show-def.el --- Minor mode for show cider definition symbol at point.

;;; Commentary:

;;; Code:

(require 'cider-common)
(require 'cider-client)
(require 'nrepl-dict)

(defvar cider-show-def-timer nil)

(defvar cider-show-def-window nil)

(defun delete-cider-show-def-window ()
  (when (and cider-show-def-window (window-live-p cider-show-def-window))
    (delete-window cider-show-def-window)
    (setq cider-show-def-window nil)))

(defun cider-show-def-handler (buf)
  (interactive)
  (if-let* ((info (cider-var-info (thing-at-point 'symbol))))
      (progn
	(let ((show-def-buffer (cider--find-buffer-for-file (nrepl-dict-get info "file")))
	      (sw (selected-window))
	      (this-scroll-margin
	       (min (max 0 scroll-margin)
		    (truncate (/ (window-body-height) 4.0)))))
	  (setq cider-show-def-window (display-buffer-in-side-window show-def-buffer '()))
	  (select-window cider-show-def-window)
	  (with-no-warnings
	    (goto-line (nrepl-dict-get info "line")))
	  (recenter-top-bottom this-scroll-margin)
	  (select-window sw)))))

(defun cancel-cider-show-def-timer ()
  (when cider-show-def-timer
    (cancel-timer cider-show-def-timer)
    (setq cider-show-def-timer nil))
  (delete-cider-show-def-window))

(defun update-cider-show-def-timer (value)
  (cancel-cider-show-def-timer)
  (setq cider-show-def-timer
        (and value (> value 0)
             (run-with-idle-timer value t 'cider-show-def-handler (current-buffer)))))

(defun cider-show-def-command-hook-handler ()
  (delete-cider-show-def-window))

(define-minor-mode cider-show-def-mode
  "Minor mode for show cider definition symbol at point."
  nil " SD" (make-sparse-keymap)
  (if cider-show-def-mode
      (progn
	(add-hook 'post-command-hook 'cider-show-def-command-hook-handler)
	(update-cider-show-def-timer 0.5))
    (remove-hook 'post-command-hook 'cider-show-def-command-hook-handler)
    (delete-cider-show-def-window)
    (cancel-cider-show-def-timer)))

(provide 'cider-show-def)
;; Local Variables:
;; End:
;;; cider-show-def.el ends here
