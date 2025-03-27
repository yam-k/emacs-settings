;;; init-helper.el --- GNU Emacs settings. -*- lexical-binding: t; coding: utf-8 -*-

;; Author: yam-k
;; URL: https://github.com/yam-k/settings
;; Version: 0.1.0
;; Keywords: init


;;; Commentary:

;; GNU Emacs の設定用の自家製関数群。
;; init.el で欲しくなる(予定の)関数をとりあえず突っ込んでおくための
;; パッケージ。


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

;;; 設定補助 =========================================================
;;;; orgファイルからの設定の読み込み ---------------------------------
(require 'ob-tangle)
(defun tangle-and-load-file (source-file &optional target-dir)
  "生成ファイルの出力先を選択できる`org-babel-load-file'.
SOURCE-FILEはorgファイルの完全パス。
TARGET-DIRは生成する.elファイルを出力するディレクトリのパス。省略すると
SOURCE-FILEと同じディレクトリに出力する。"
  (let* ((target-dir (or target-dir
                         (file-name-directory source-file)
                         user-emacs-directory))
         (target-file (file-name-concat
                       target-dir
                       (file-name-with-extension
                        (file-name-nondirectory source-file) ".el"))))
    (org-babel-tangle-file source-file target-file)
    (load target-file)))

;;;; package-installの改造 -------------------------------------------
(defun package-install-retry-advice (func &rest args)
  "`package-install'が失敗した時に再挑戦するようにするadvice.
:aroundに適用すると、失敗時に`package-refresh-contents'を評価した上で
再度パッケージの取得を試みる。2回目も失敗するとエラーとなる。
FUNCはpackage-install、ARGSはpackage-installに渡す引数。"
  (condition-case err
      (apply func args)
    (error (progn (package-refresh-contents)
                  (apply func args)))))

;;;; define-keyの代替マクロ ------------------------------------------
(defmacro setkey (map &rest args)
  "キーバインド設定用マクロ.

(setkey global-map
  \"C-n\" #'next-line
  \"C-p\" #'previous-line)
のように、1つのキーマップに対して一度に複数のキーバインドを列挙できる。

MAPは設定したいキーマップ、KEYは`kbd'に渡せるキーシーケンス文字列、
FUNCTIONはキーシーケンスに対して設定したい関数。
ARGSは、[KEY FUNCTION]..."
  (declare (indent defun))
  (when args
    (let ((sets '()))
      (while args
        (add-to-list 'sets (cons (pop args) (pop args))))
      `(progn
         ,@(mapcar (lambda (set)
                     `(define-key ,map (kbd ,(car set)) ,(cdr set)))
                   (reverse sets))))))

;;;; add-to-list -----------------------------------------------------
(defun add-elements-to-list (list-var &rest elements)
  "`add-to-list'をたくさん書く時に楽をする用の関数."
  (declare (indent defun))
  (mapc (lambda (element)
          (add-to-list list-var element))
        elements)
  list-var)


;;; いろいろ制御 =====================================================
;;;; ウィンドウを逆順に巡回する --------------------------------------
(defun select-previous-window ()
  "一つ前のウィンドウをフォーカスする."
  (interactive)
  (other-window -1))

;;;; 表示のトグル ----------------------------------------------------
(defun fringe-minimize ()
  "編集領域両側のfringeを最小化(size=1)したり戻したり(size=8)."
  (interactive)
  (cond ((null fringe-mode) (setopt fringe-mode 1))
        ((= fringe-mode 1) (setopt fringe-mode 8))
        (t (setopt fringe-mode 1))))

(defun tab-bar-show ()
  "タブバーの表示をトグルする."
  (interactive)
  (cond ((null tab-bar-show) (setopt tab-bar-show t))
        (t (setopt tab-bar-show nil))))

;;;; pulseaudio-utilsのコントロール ----------------------------------
(defun audio-raise-volume ()
  "システムの音量を上げる."
  (interactive)
  (call-process "pactl" nil nil nil
                "set-sink-volume" "@DEFAULT_SINK@" "+5%"))

(defun audio-lower-volume ()
  "システムの音量を下げる."
  (interactive)
  (call-process "pactl" nil nil nil
                "set-sink-volume" "@DEFAULT_SINK@" "-5%"))

(defun audio-toggle-mute ()
  "システム音量のミュートをトグルする."
  (interactive)
  (call-process "pactl" nil nil nil
                "set-sink-mute" "@DEFAULT_SINK@" "toggle"))

;;; feature として登録 ===============================================
(provide 'init-helper)

;;; init-helper.el ends here
