;;; keybind-collection.el --- Jibun-you Keybinds -*- lexical-binding: t; coding: utf-8 -*-

;; Author: yam-k
;; URL: https://github.com/yam-k/settings
;; Version: 0.1.0
;; Keywords: init


;;; Commentary:

;; モードに応じて動的に変更されるキーマップ.


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

(require 'which-key)

(defcustom keybind-collection-prefix-key "C-z"
  "keybind-collectionのプレフィクスキー.")

(defcustom keybind-collection-name-prefix "kc/"
  "keybind-collectionが作成するキーマップ名のプレフィクス.")

(defcustom keybind-collection-use-static-collection t
  "固定メニューを使うかどうか.")

(defcustom keybind-collection-static-collection-prefix-key "<RET>"
  "固定メニューを呼びだすキーバインド.
`keybind-collection-prefix-key'の挿下後にこのキーを押す。")

(defcustom keybind-collection-static-collection-name "kc/static"
  "固定メニュー用のキーマップ名.")

(defcustom keybind-collection-static-collection-display-name "static"
  "固定メニュー用のキーマップの表示名.")

(defvar keybind-collection-alist '()
  "モード毎のキーマップを保持するalist.
各要素は、(モード キーマップ which-keyでの表示名)。")

(define-prefix-command 'keybind-collection-map)
(define-prefix-command (intern keybind-collection-static-collection-name))

(defun keybind-collection--define-keys-1 (keymap bindings)
  "`keybind-collection-define-keys'の実体.
BINDINGSが空でなければKEYMAPにキーバインドを再起的に設定する。"
  (when bindings
    (define-key keymap (kbd (nth 0 bindings)) (nth 1 bindings))
    (keybind-collection--define-keys-1 keymap (nthcdr 2 bindings))))

(defun keybind-collection-define-keys (keymap &rest bindings)
  "KEYMAPに対して複数のキーバインドを設定する.
BINDINGSは、[文字列 関数]...。
文字列は、関数を呼び出すキーストロークで、`kbd'に渡せるもの。"
  (declare (indent defun))
  (keybind-collection--define-keys-1 keymap bindings)
  keymap)

(defun keybind-collection-set-collection (mode prefix disp-name &rest bindings)
  ""
  (declare (indent defun))
  (let ((collection (intern (concat keybind-collection-name-prefix
                                    (symbol-name mode))))
        (disp (if disp-name disp-name (symbol-name mode))))
    (define-prefix-command collection)
    (add-to-list 'keybind-collection-alist
                 (list mode prefix collection))
    (add-to-list 'which-key-replacement-alist
                 (cons (cons nil (symbol-name collection))
                       (cons nil disp)))
    (keybind-collection--define-keys-1 collection bindings)))

(defun keybind-collection-set-static-collection (prefix disp-name &rest bindings)
  ""
  (declare (indent defun))
  (let ((collection (intern (concat (or keybind-collection-static-collection-display-name
                                        keybind-collection-static-collection-name)
                                    "/"
                                    (or disp-name prefix)))))
    (define-prefix-command collection)
    (define-key (intern keybind-collection-static-collection-name)
                (kbd prefix)
                collection)
    (add-to-list 'which-key-replacement-alist
                 (cons (cons nil (symbol-name collection))
                       (cons nil disp-name)))
    (keybind-collection--define-keys-1 collection bindings)))

(defun keybind-collection--generate-collection ()
  ""
  (define-key keybind-collection-map
                (kbd keybind-collection-static-collection-prefix-key)
                (and keybind-collection-use-static-collection
                     (intern keybind-collection-static-collection-name)))
  (mapc (lambda (element)
          (let ((mode (nth 0 element))
                (key (nth 1 element))
                (collection (nth 2 element)))
            (if (or (eq major-mode mode) (member mode local-minor-modes))
                (define-key keybind-collection-map (kbd key) collection)
              (define-key keybind-collection-map (kbd key) nil))))
        keybind-collection-alist)
  keybind-collection-map)

(defun keybind-collection-initialize ()
  (define-key global-map (kbd keybind-collection-prefix-key) 'keybind-collection-map)
  (add-to-list 'which-key-replacement-alist
               (cons (cons nil keybind-collection-static-collection-name)
                     (cons nil (or keybind-collection-static-collection-display-name
                                   keybind-collection-static-collection-name))))
  (keybind-collection--generate-collection)
  (add-hook 'buffer-list-update-hook #'keybind-collection--generate-collection))


(provide 'keybind-collection)

;;; keybind-collection.el ends here
