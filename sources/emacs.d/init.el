;;; -*- lexical-binding: t; coding: utf-8 -*-

(add-to-list 'load-path (expand-file-name "utils/" user-emacs-directory))

(require 'init-utils)
(require 'util-commands)
(require 'keymap-utils)

(keymap-utils-init)

(with-init-utils
 (init-utils-load-org
   (expand-file-name "emacs-settings.org" user-emacs-directory)))
