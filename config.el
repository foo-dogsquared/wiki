(defvar +wiki-directory "~/writings/wiki")
(defvar +wiki-notebook-name "notebook")
(defvar +wiki-notebook-directory (f-join +wiki-directory +wiki-notebook-name))
(defvar my/wiki-asset-directory-name "assets")

(+wiki/biblio-setup)

(defun my/is-in-wiki-directory (&optional filename)
  "Return t if the file buffer is in the wiki directory."
  (unless filename (setq filename (buffer-file-name)))
  (if (and (not (string= (f-base filename)
                         my/wiki-asset-directory-name))
           (f-descendant-of-p filename
                              (expand-file-name +wiki-directory)))
      t
    nil))

(defun my/get-assets-folder (&optional filename)
  "Get the assets folder of the current Org mode document."
  (unless filename (setq filename (buffer-file-name)))
  (if (my/is-in-wiki-directory filename)
      (f-join my/wiki-asset-directory-name (f-base filename))
    nil))

(defun my/concat-assets-folder (&optional filename &rest args)
  "Concatenate PATH to the assets folder."
  (unless filename (setq filename (buffer-file-name)))
  (apply #'f-join (my/get-assets-folder filename) args))

(defun my/create-assets-folder (&optional filename)
  "A quick convenient function to create the appropriate folder in the assets folder with its buffer filename."
  (interactive)
  (unless filename (setq filename (buffer-file-name)))
  (if (my/is-in-wiki-directory)
      (let* ((target (f-base filename))
             (target-dir (f-join my/wiki-asset-directory-name target)))
        (apply #'f-mkdir (f-split target-dir))
        (message "Directory '%s' has been created." target-dir))
    (message "Not in the wiki directory.")))

(defun my/parse-links-in-org (&optional filename)
  "Returns a list of links in an Org buffer."
  (unless filename (setq filename (buffer-file-name)))
  (let ((ast (with-temp-buffer
               (insert-file-contents filename)
               (org-mode)
               (org-element-parse-buffer))))
    (org-element-map ast 'link
      (lambda (link)
        (when (or (string= (org-element-property :type link) "http")
                  (string= (org-element-property :type link) "https"))
          (org-element-property :path link))))))

(defun my/anki-editor-delete-note ()
  "Request AnkiConnect for deleting a note at point."
  (interactive)
  (let ((queue (anki-editor--anki-connect-invoke-queue)))
    (funcall queue
             'deleteNotes
             `((notes . ,(list (org-entry-get (point) anki-editor-prop-note-id)))))
    (org-entry-delete (point) anki-editor-prop-note-id)))

(setq
 org-roam-v2-ack 't
 org-roam-node-display-template
 (format "${doom-hierarchy:*} %s %s"
         (propertize "${doom-tags:15}" 'face 'org-tag)
         (propertize "${file:60}" 'face 'font-lock-default-face))

 citar-notes-paths `(,+wiki-directory)
 citar-library-paths '("~/library/references" "~/Zotero")

 org-roam-capture-templates `(("e" "evergreen" plain "%?"
                               (file ,(f-join +wiki-directory "templates" "default.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "%<%Y-%m-%d-%H-%M-%S>.org"))
                               :unnarrowed t)

                              ("c" "cards" plain "%?"
                               (file ,(f-join +wiki-directory "templates" "anki.org"))
                               :target
                               (file ,(f-join +anki-cards-directory-name "%<%Y>.org"))
                               :unnarrowed t
                               :empty-lines 2)

                              ("l" "literature" plain "%?"
                               (file ,(f-join +wiki-directory "templates" "default.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "literature.${slug}.org"))
                               :unnarrowed t)

                              ("L" "literature reference" plain "%?"
                               (file ,(f-join +wiki-directory "templates" "literature.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "literature.${citekey}.org"))
                               :unnarrowed t)

                              ("d" "dailies" entry "* %?"
                               :target
                               (file+head ,(expand-file-name "%<%Y-%m-%d>.org" org-roam-dailies-directory) "#+title: %<%Y-%m-%d>\n"))

                              ("s" "structured" plain "%?"
                               (file ,(f-join +wiki-directory "templates" "default.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "${slug}.org"))
                               :unnarrowed t)))
;;; config.el ends here
