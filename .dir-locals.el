((org-mode .
           ((org-babel-default-header-args . ((:session . "none")
                                              (:results . "replace output")
                                              (:exports . "both")
                                              (:cache . "no")
                                              (:noweb . "yes")
                                              (:mkdirp . "yes")
                                              (:tangle . "no")))
            (org-babel-default-header-args:org . ((:results . "silent")
                                                  (:exports . "code")))
            (citar-open-note-function 'orb-citar-edit-note)
            (time-stamp-format . "%Y-%02m-%02d %02H:%02M:%02S %:z")
            (time-stamp-start . "date_modified:[ 	]+\\\\?[\"< ]*")
            (time-stamp-end . "\\\\?[\"> ]*$")
            (eval . (setq org-babel-default-header-args
                          (cons `(:output-dir . ,(f-join
                                                  (file-name-directory (buffer-file-name))
                                                  "assets"
                                                  (file-name-base (buffer-file-name))))
                                (assq-delete-all :output-dir org-babel-default-header-args))

                          citar-note-format-function
                          (lambda (key entry)
                            (let* ((template (citar--get-template 'note))
                                   (note-meta (when template
                                                (citar-format--entry template entry)))
                                   (filepath (expand-file-name
                                              (f-join "notebook/" (concat "literature." key ".org"))
                                              (car citar-notes-paths)))
                                   (buffer (find-file filepath)))
                              (with-current-buffer buffer
                                (erase-buffer)
                                (citar-org-roam-make-preamble key)
                                (org-roam-capture--fill-template "r")
                                (insert "\n\n|\n\n#+print_bibliography:")
                                (search-backward "|")
                                (delete-char 1)
                                (when (fboundp 'evil-insert)
                                  (evil-insert 1)))))))
            (org-babel-results-keyword . "results"))))
