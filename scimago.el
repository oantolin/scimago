;;; scimago.el --- Lookup Scimago quartiles          -*- lexical-binding: t; -*-

(require 'tabulated-list)

(defcustom scimago-data-file
  (expand-file-name
   "data/mathsjr.lisp"
   (file-name-directory (locate-library "scimago")))
  "Location of files containing Scimago data."
  :group 'scimago
  :type 'file)

(defvar scimago-data
  (with-temp-buffer
    (insert-file-contents-literally scimago-data-file)
    (goto-char (point-min))
    (read (current-buffer)))
  "Alist of Scimago journals, years and quartiles.")

(defun scimago--quartiles (journal)
  "Return alist of years and quartiles for JOURNAL."
  (cl-loop for (j y q) in scimago-data
           when (equal journal j) collect (cons y q)))

(defun scimago-show-quartiles (journal)
  "Display quartile data for JOURNAL."
  (interactive (list (completing-read "Journal: " scimago-data)))
  (let ((buffer (get-buffer-create (format "*Journal: %s" journal))))
    (with-current-buffer buffer
      (tabulated-list-mode)
      (setq tabulated-list-format [("Year" 4 t) ("Quartiles" 0 nil)]
            tabulated-list-entries
            (cl-loop for (y q) in (scimago--quartiles journal)
                     collect (list y (vector y q))))
      (tabulated-list-init-header)
      (tabulated-list-print))
    (pop-to-buffer buffer)
    (shrink-window-if-larger-than-buffer)))

(defun scimago-copy-quartiles (journal year)
  "Display quartile data for JOURNAL."
  (interactive
   (let* ((journal (completing-read "Journal: " scimago-data))
          (year
           (completing-read
            "Year: "
            (let ((quartiles (scimago--quartiles journal)))
              (lambda (string predicate action)
                (if (eq action 'metadata)
                    `(metadata
                      (display-sort-function . identity)
                      (cycle-sort-function . identity)
                      (annotation-function
                       . ,(lambda (year)
                            (concat
                             " "
                             (alist-get year quartiles nil nil #'equal)))))
                  (complete-with-action
                   action quartiles string predicate)))))))
     (list journal year)))
   (let ((qs (alist-get year (scimago--quartiles journal) "" nil #'equal)))
     (message "Copied: %s" qs)
     (kill-new qs)))

(provide 'scimago)
;;; scimago.el ends here
