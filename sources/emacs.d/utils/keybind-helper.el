;;; keybind-helper.el --- GNU Emacs settings. -*- lexical-binding: t; coding: utf-8 -*-

;; Author: yam-k
;; URL: https://github.com/yam-k/settings
;; Version: 0.1.0
;; Keywords: init


;;; Commentary:

;; 気が向いたら何か説明を書く。


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

(defcustom keybind-helper-prefix "C-z"
  "keybind-helperで作成したキーマップを呼び出すキー."
  :type 'string)

(defcustom keybind-helper-keymap-name-prefix "kh/"
  "keybind-helperで作成したキーマップ名の頭に付ける文字."
  :type 'string)

(defcustom keybind-helper-dynamic-prefix "C-z"
  "`keybind-helper-map'から動的キーマップを呼び出すキー."
  :type 'string)

(defcustom keybind-helper-dynamic-map-display-name "mode-specific"
  "動的キーマップの`which-key'での表示名.")

(defvar keybind-helper-dynamic-alist '()
  "動的なキーマップを保持するalist.")

(define-keymap :prefix 'keybind-helper-map)
(define-keymap :prefix 'keybind-helper-dynamic-map)
(keymap-set keybind-helper-map
            keybind-helper-dynamic-prefix 'keybind-helper-dynamic-map)
(add-to-list 'which-key-replacement-alist
             (cons (cons nil (symbol-name 'keybind-helper-dynamic-map))
                   (cons nil keybind-helper-dynamic-map-display-name)))

(defun keybind-helper-keymap-symbol (name)
  "keybind-helperで作成したキーマップを表すシンボルを返す.
NAMEは、作成時に指定した文字列。"
  (intern (concat keybind-helper-keymap-name-prefix name)))

(defun keybind-helper-keymap (name)
  "keybind-helperで作成したキーマップを返す.
NAMEは、作成時に指定した文字列。"
  (symbol-value (keybind-helper-keymap-symbol name)))

(defun keybind-helper--keymap-set (keymap definitions)
  "`keybind-helper-define-keymap'のキーマップ設定用関数."
  (when definitions
    (keymap-set keymap (nth 0 definitions) (nth 1 definitions))
    (keybind-helper--keymap-set keymap (nthcdr 2 definitions))))

(defun keybind-helper-define-keymap (mode name prefix-key &rest definitions)
  "モードに応じた動的キーマップを作成する.
MODEは、nil又はモードを表すシンボル。MODEがnilであれば、モードによらず
常に有効なキーバインドとして設定する。
NAMEは、作成するキーマップに束縛するシンボルを構成する文字列。実際の
シンボルは、`keybind-helper-keymap-name-prefix'と結合されたもの。
また、`which-key'での表示名にもなる。
PREFIX-KEYは、`keybind-helper-map'内でのキーバインド文字列。
DEFINITIONSは、[KEY DEFINITION]...。`keymap-set'と同じ。"
  (condition-case nil
      (keybind-helper-keymap name)
    (error (define-prefix-command (keybind-helper-keymap-symbol name))))

  (keybind-helper--keymap-set (keybind-helper-keymap name) definitions)

  ;; モードが指定されていればdynamic-alistに追加。
  ;; nilなら、常時表示用に設定。
  (if mode
      (add-to-list 'keybind-helper-dynamic-alist (list mode name prefix-key))
    (let ((symbol (keybind-helper-keymap-symbol name)))
      (keymap-set keybind-helper-map prefix-key symbol)
      (add-to-list 'which-key-replacement-alist
                   (cons (cons nil (symbol-name symbol))
                         (cons nil name)))))

  (keybind-helper-keymap-symbol name))

(defun keybind-helper--set-dynamic (lst)
  "メジャーモードまたはマイナーモードに応じたキーバインドを設定する.
LSTは、(MODE NAME PREFIX-KEY)。
MODEは、モードを表すシンボル。
NAMEは、keybind-helperで作成したキーマップ名。
PREFIX-KEYは、動的キーマップでの呼出キー。"
  (let* ((mode (nth 0 lst))
         (name (nth 1 lst))
         (prefix-key (nth 2 lst))
         (symbol (keybind-helper-keymap-symbol name)))
    (if (or (eq mode major-mode)
            (member mode local-minor-modes))
        (progn (keymap-set keybind-helper-dynamic-map prefix-key symbol)
               (add-to-list 'which-key-replacement-alist
                            (cons (cons nil (symbol-name symbol))
                                  (cons nil name))))
      (keymap-unset keybind-helper-dynamic-map prefix-key t))))

(defun keybind-helper--construct-dynamic ()
  "`keybind-helper-dynamic-alist'の各要素に対して`keybind-helper--set-dynamic'を実行する."
  (mapc #'keybind-helper--set-dynamic keybind-helper-dynamic-alist))

(defun keybind-helper-init ()
  "キーマップを有効にする."
  (keymap-set global-map keybind-helper-prefix 'keybind-helper-map)
  (add-to-list 'buffer-list-update-hook #'keybind-helper--construct-dynamic))

;;; feature として登録 ===============================================
(provide 'keybind-helper)

;;; keybind-helper.el ends here
