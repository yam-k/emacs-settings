;;; keymap-utils.el --- GNU Emacs settings. -*- lexical-binding: t; coding: utf-8 -*-

;; Author: yam-k
;; Version: 0.1.0
;; Keywords: init


;;; Commentary:

;; * 変数
;; ** keymap-utils-keymap-prefix
;; keymap-utilsが作成するキーマップの接頭辞。
;;
;; ** keymap-utils-static-map-prefix
;; keymap-utils-static-mapを呼び出すキー。
;;
;; ** keymap-utils-dynamic-map-prefix
;; keymap-utils-dynamic-mapを呼び出すキー。
;;
;; * 関数
;; ** keymap-utils-keymap-set
;; setqみたいにkeymap-setを書けるようにした。
;;
;; ** keymap-utils-init
;; keymap-utils-static-mapとkeymap-utils-dynamic-mapにキーバインドを
;; 割り当てる。
;;
;; ** keymap-utils-static-map-set
;; keymap-utils-static-mapにキーバインドを設定する。
;;
;; ** keymap-utils-dynamic-map-set
;; keymap-utils-dynamic-mapにキーバインドを設定する。


;;; License:

;; This file is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.


;;; Code:

;;;; 依存パッケージ ================================================
(require 'which-key)


;;;; 変数 ==========================================================
(defcustom keymap-utils-keymap-prefix "kh/"
  "サブキーマップの接頭辞."
  :type 'string)

(defcustom keymap-utils-static-map-prefix "C-z"
  "keymap-utils-static-mapを呼び出すキーバインド."
  :type 'string)

(defcustom keymap-utils-dynamic-map-prefix
  (concat keymap-utils-static-map-prefix " C-z")
  "keymap-utils-dynamic-mapを呼び出すキーバインド."
  :type 'string)

(defvar keymap-utils--dynamic-map-alist '()
  "モードごとのサブキーマップを保持するalist.")


;;;; 関数 ==========================================================
(defun keymap-utils--divide-list-into-n (list n)
  "LISTを先頭から順にN個ずつのリストのリストに変換する."
  (when list
    (cons (take n list)
          (keymap-utils--divide-list-into-n (nthcdr n list) n))))

(defun keymap-utils-keymap-set (keymap &rest definitions)
  "KEYMAPに同時に複数のキーバインドを設定する.
DEFINITIONSは[KEY DEFINITION]...。
KEYは、`key-valid-p'がtとなる文字列。
許容されるDEFINITIONは、`keymap-set'を参照。"
  (declare (indent defun))
  (let ((definitions (keymap-utils--divide-list-into-n definitions 2)))
    (mapcar (lambda (definition)
              (apply #'keymap-set keymap definition))
            definitions)))

(defun keymap-utils--name-to-keymap (name)
  "NAMEに対応するサブキーマップのシンボルを返す."
  (intern (concat keymap-utils-keymap-prefix name)))

(defun keymap-utils--set-which-key-replacement-alist (keymap name)
  "`which-key'でKEYMAP名の代わりにNAMEを表示させる."
  (declare (indent defun))
  (add-to-list 'which-key-replacement-alist
               (cons (cons nil (symbol-name keymap))
                     (cons nil name))))

(defun keymap-utils-static-map-set (name key &rest definitions)
  "`keymap-utils-static-map'にサブキーマップを登録する.
NAMEは、`which-key'での表示名。
KEYは、keymap-utils-static-map内でサブキーマップを呼び出すキー。
DEFINITIONSは、サブキーマップでのキーバインドの定義で、
`keymap-utils-keymap-set'のものと同じ。"
  (declare (indent defun))
  (let ((keymap (keymap-utils--name-to-keymap name)))
    (unless (keymapp (symbol-function keymap))
      (define-keymap :prefix keymap))
    (apply #'keymap-utils-keymap-set
           (symbol-function keymap)
           definitions)
    (keymap-set keymap-utils-static-map key keymap)
    (keymap-utils--set-which-key-replacement-alist keymap name)))

(defun keymap-utils-dynamic-map-set (mode key &rest definitions)
  "`keymap-utils--dynamic-map-alist'にサブキーマップを登録する.
NAMEは、`which-key'での表示名。
KEYは、keymap-utils-dynamic-map内でサブキーマップを呼び出すキー。
DEFINITIONSは、サブキーマップでのキーバインドの定義で、
`keymap-utils-keymap-set'のものと同じ。"
  (declare (indent defun))
  (let* ((name (symbol-name mode))
         (keymap (keymap-utils--name-to-keymap name)))
    (unless (keymapp (symbol-function keymap))
      (define-keymap :prefix keymap))
    (apply #'keymap-utils-keymap-set
           (symbol-function keymap)
           definitions)
    (push (list mode key) keymap-utils--dynamic-map-alist)
    (keymap-utils--set-which-key-replacement-alist keymap name)))

(defun keymap-utils--activate-dynamic-menu (mode key)
  "MODEに応じてサブキーマップの使用可否を変更する.
KEYは、keymap-utils-dynamic-map内でサブキーマップを呼び出すキー。"
  (let* ((name (symbol-name mode))
         (keymap (keymap-utils--name-to-keymap name)))
    (if (or (equal mode major-mode) (member mode local-minor-modes))
        (keymap-set keymap-utils-dynamic-map key keymap)
      (keymap-unset keymap-utils-dynamic-map key t))))

(defun keymap-utils--construct-dynamic-map ()
  "モードに応じてkeymap-utils-dynamic-mapを再構成する."
  (mapc (lambda (lst)
          (apply #'keymap-utils--activate-dynamic-menu lst))
        keymap-utils--dynamic-map-alist))

(defun keymap-utils-init ()
  "keymap-utils-static-mapとkeymap-utils-dynamic-mapを有効化."
  (define-keymap :prefix 'keymap-utils-static-map)
  (define-keymap :prefix 'keymap-utils-dynamic-map)

  (keymap-set global-map
              keymap-utils-static-map-prefix 'keymap-utils-static-map)

  (keymap-utils--set-which-key-replacement-alist
    'keymap-utils-static-map "static")
  (keymap-utils--set-which-key-replacement-alist
    'keymap-utils-dynamic-map "dynamic")

  (add-to-list 'buffer-list-update-hook
               #'keymap-utils--construct-dynamic-map))


;;;; feature として登録 ============================================
(provide 'keymap-utils)


;;; keymap-utils.el ends here
