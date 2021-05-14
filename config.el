(defvar +wiki-directory "~/writings/wiki")
(defvar my/wiki-asset-directory-name "assets")

(defun my/is-in-wiki-directory ()
    "Return t if the file buffer is in the wiki directory."
  (if (and (not (string= (f-base (buffer-file-name))
                         my/wiki-asset-directory-name))
           (f-descendant-of-p (buffer-file-name)
                              (expand-file-name +wiki-directory)))
      t
    nil))

(defun my/get-assets-folder ()
    "Get the assets folder of the current Org mode document."
  (if (my/is-in-wiki-directory)
      (f-join my/wiki-asset-directory-name (f-base buffer-file-name))
    nil))

(defun my/concat-assets-folder (path)
  "Concatenate PATH to the assets folder."
  (f-join (my/get-assets-folder) path))

(defun my/create-assets-folder ()
  "A quick convenient function to create an assets folder in the wiki folder."
  (interactive)
  (if (my/is-in-wiki-directory)
      (f-mkdir my/wiki-asset-directory-name
               (f-join my/wiki-asset-directory-name (file-name-sans-extension (buffer-file-name))))
    (message "Not in the wiki directory.")))

(defun my/anki-editor-delete-note ()
  "Request AnkiConnect for deleting a note at point."
  (interactive)
  (let ((queue (anki-editor--anki-connect-invoke-queue)))
    (funcall queue
             'deleteNotes
             `((notes . ,(list (org-entry-get (point) anki-editor-prop-note-id)))))
    (org-entry-delete (point) anki-editor-prop-note-id)))

;;; config.el ends here
