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
          (eval . (setq org-babel-default-header-args
                        (cons `(:dir . ,(concat
                                         (file-name-directory (buffer-file-name))
                                         "assets/"
                                         (file-name-base (buffer-file-name))))
                              (assq-delete-all :dir org-babel-default-header-args))))
          (org-babel-results-keyword . "results"))))
