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

(defun my/concat-assets-folder (&rest args)
  "Concatenate PATH to the assets folder."
  (apply #'f-join (my/get-assets-folder (buffer-file-name)) args))

(defun my/create-assets-folder (&optional filename)
  "A quick convenient function to create the appropriate folder in the assets
folder with its buffer filename."
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

 citar-notes-paths `(,+wiki-directory)
 citar-library-paths '("~/library/references" "~/Zotero")

 org-roam-capture-templates `(("e" "evergreen" plain
                               (file ,(f-join +wiki-directory "templates" "default.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "%<%Y-%m-%d-%H-%M-%S>.org"))
                               :unnarrowed t)

                              ("c" "cards" plain
                               (file ,(f-join +wiki-directory "templates" "anki.org"))
                               :target
                               (file ,(f-join +anki-cards-directory-name "%<%Y>.org"))
                               :unnarrowed t
                               :empty-lines 2)

                              ("l" "literature" plain
                               (file ,(f-join +wiki-directory "templates" "default.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "literature.${slug}.org"))
                               :unnarrowed t)

                              ("L" "literature reference" plain
                               (file ,(f-join +wiki-directory "templates" "literature.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "literature.${citekey}.org"))
                               :unnarrowed t)

                              ("d" "dailies" entry "* %?"
                               :target
                               (file+head ,(expand-file-name "%<%Y-%m-%d>.org" org-roam-dailies-directory) "#+title: %<%Y-%m-%d>\n"))

                              ("s" "structured" plain
                               (file ,(f-join +wiki-directory "templates" "default.org"))
                               :target
                               (file ,(f-join +wiki-notebook-directory "${slug}.org"))
                               :unnarrowed t)))

(eval-after-load "org-roam"
  '(cl-defmethod org-roam-node-slug ((node org-roam-node))
     "Override of the original org-roam slug function by replacing the
underscore with dashes."
     (let ((title (org-roam-node-title node))
           (slug-trim-chars '(;; Combining Diacritical Marks https://www.unicode.org/charts/PDF/U0300.pdf
                              768      ; U+0300 COMBINING GRAVE ACCENT
                              769      ; U+0301 COMBINING ACUTE ACCENT
                              770      ; U+0302 COMBINING CIRCUMFLEX ACCENT
                              771      ; U+0303 COMBINING TILDE
                              772      ; U+0304 COMBINING MACRON
                              774      ; U+0306 COMBINING BREVE
                              775      ; U+0307 COMBINING DOT ABOVE
                              776      ; U+0308 COMBINING DIAERESIS
                              777      ; U+0309 COMBINING HOOK ABOVE
                              778      ; U+030A COMBINING RING ABOVE
                              779      ; U+030B COMBINING DOUBLE ACUTE ACCENT
                              780      ; U+030C COMBINING CARON
                              795      ; U+031B COMBINING HORN
                              803      ; U+0323 COMBINING DOT BELOW
                              804      ; U+0324 COMBINING DIAERESIS BELOW
                              805      ; U+0325 COMBINING RING BELOW
                              807      ; U+0327 COMBINING CEDILLA
                              813      ; U+032D COMBINING CIRCUMFLEX ACCENT BELOW
                              814      ; U+032E COMBINING BREVE BELOW
                              816      ; U+0330 COMBINING TILDE BELOW
                              817      ; U+0331 COMBINING MACRON BELOW
                              )))
       (cl-flet* ((nonspacing-mark-p (char) (memq char slug-trim-chars))
                  (strip-nonspacing-marks (s) (string-glyph-compose
                                               (apply #'string
                                                      (seq-remove #'nonspacing-mark-p
                                                                  (string-glyph-decompose s)))))
                  (cl-replace (title pair) (replace-regexp-in-string (car pair) (cdr pair) title)))
         (let* ((pairs `(("[^[:alnum:][:digit:]]" . "-") ;; convert anything not alphanumeric
                         ("--*" . "-") ;; remove sequential dashes
                         ("^_" . "")   ;; remove starting dashes
                         ("_$" . ""))) ;; remove ending dashes
                (slug (-reduce-from #'cl-replace (strip-nonspacing-marks title) pairs)))
           (downcase slug))))))

(eval-after-load "org-roam"
  '(setq
    org-roam-node-display-template
    (format "${doom-hierarchy:*} %s %s"
            (propertize "${doom-tags:15}" 'face 'org-tag)
            (propertize "${file:60}" 'face 'font-lock-default-face))))
;;; config.el ends here
