;;; init.el --- GNU Emacs settings. -*- lexical-binding: t; coding: utf-8 -*-

;;;; デフォルトの文字コード ------------------------------------------
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-emacs-unix)

;;;; ロードパスの設定 ------------------------------------------------
(add-to-list 'load-path
             (expand-file-name "utils/" user-emacs-directory))

;;;; 自作関数群の読み込み --------------------------------------------
(require 'init-helper)

;;;; 実設定ファイルの読み込み ----------------------------------------
(let ((tmp-dir (expand-file-name "tmp/" user-emacs-directory)))
  (unless (file-exists-p tmp-dir)
    (make-directory tmp-dir t))
  (tangle-and-load-file  ;from init-helper
   (expand-file-name "emacs-settings.org" user-emacs-directory)
   tmp-dir))

;;; init.el ends here
