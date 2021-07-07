(defvar +wiki-directory "~/writings/wiki")
(defvar +structured-notes-directory-name "structured")
(defvar +structured-notes-directory (f-join +wiki-directory +structured-notes-directory-name))
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

(defun my/concat-assets-folder (&rest args)
  "Concatenate PATH to the assets folder."
  (apply #'f-join (my/get-assets-folder) args))

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

(setq
 org-roam-capture-templates `(("p" "permanent" plain "%?"
                               :if-new
                               (file+head "%<%Y-%m-%d-%H-%M-%S>.org"
                                          "#+title: ${title}
#+date: \"%<%Y-%m-%d %T %:z>\"
#+date_modified: \"%<%Y-%m-%d %T %:z>\"
#+language: en")
                               :unnarrowed t)

                              ("c" "cards" plain "%?"
                               :if-new
                               (file+head ,(f-join +anki-cards-directory-name "%<%Y>.org") "#+title: Anki: ${title}
#+date: \"%<%Y-%m-%d %T %:z>\"
#+date_modified: \"%<%Y-%m-%d %T %:z>\"
#+language: en
#+property: anki_deck ${title}")
                               :unnarrowed t)

                              ("l" "literature" plain "%?"
                               :if-new
                               (file+head ,(f-join +structured-notes-directory-name "literature.${slug}.org") "#+title: ${title}
#+date: \"%<%Y-%m-%d %T %:z>\"
#+date_modified: \"%<%Y-%m-%d %T %:z>\"
#+language: en")
                               :unnarrowed t)

                              ("d" "dailies" entry "* %?"
                               :if-new
                               (file+head ,(expand-file-name "%<%Y-%m-%d>.org" org-roam-dailies-directory) "#+title: %<%Y-%m-%d>\n"))

                              ("s" "structured" plain "%?"
                               :if-new
                               (file+head ,(f-join +structured-notes-directory-name "${slug}.org") "#+title: ${title}")
                               :unnarrowed t)))

(eval-after-load "org-roam"
  '(cl-defmethod org-roam-node-slug ((node org-roam-node))
     "Override the slug method with a kebab-case instead of the
snake_case."
     (let ((title (org-roam-node-title node)))
       (cl-flet* ((nonspacing-mark-p (char)
                                     (memq char org-roam-slug-trim-chars))
                  (strip-nonspacing-marks (s)
                                          (ucs-normalize-NFC-string
                                           (apply #'string (seq-remove #'nonspacing-mark-p
                                                                       (ucs-normalize-NFD-string s)))))
                  (cl-replace (title pair)
                              (replace-regexp-in-string (car pair) (cdr pair) title)))
         (let* ((pairs `(("[^[:alnum:][:digit:]_.]+" . "-")  ;; convert anything not alphanumeric except "."
                         ("\s+" . "-")    ;; remove whitespaces
                         ("__*" . "-")  ;; remove sequential underscores
                         ("^_" . "")  ;; remove starting underscore
                         ("_$" . "")))  ;; remove ending underscore
                (slug (-reduce-from #'cl-replace (strip-nonspacing-marks title) pairs)))
           (downcase slug))))))
;;; config.el ends here
