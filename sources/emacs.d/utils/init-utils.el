;;; init-utils.el --- GNU Emacs setting utils. -*- lexical-binding: t; coding: utf-8 -*-

;; Author: yam-k
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

;;;; 依存パッケージ ================================================
(require 'ob-tangle)


;;;; 変数 ==========================================================
(defcustom init-utils-tmp-dir
  (expand-file-name "tmp" user-emacs-directory)
  "orgファイルから抽出したelファイルを保存しておくディレクトリ."
  :type 'string)


;;;; 関数 ==========================================================
(defun init-utils--tmp-dir-make ()
  "`init-utils-tmp-dir'が無ければ作る."
  (cond ((file-directory-p init-utils-tmp-dir) nil)
        ((file-exists-p init-utils-tmp-dir)
         (error (format "`%s'がファイルとして存在するので、ディレクトリを作成できない."
                        init-utils-tmp-dir)))
        (t (make-directory init-utils-tmp-dir t))))

(defun init-utils-load-org (org-file)
  "ORG-FILEからelファイルを抽出し読み込む.
ORG-FILEは、コードブロックにEmacs Lispを記したorgファイルへの絶対パス。"
  (declare (indent defun))
  (init-utils--tmp-dir-make)
  (let* ((org-file (expand-file-name org-file))
         (source-file (file-name-nondirectory org-file))
         (target-file-name (file-name-with-extension source-file ".el"))
         (target-file (file-name-concat init-utils-tmp-dir
                                        target-file-name)))
    (org-babel-tangle-file org-file target-file)
    (load target-file)))

(defun init-utils--package-install-advice (func &rest args)
  "パッケージが無い時のみ、`package-install'を有効にするadvice.
また、`package-install'が失敗した時は、`package-refresh-contents'を
実行した後で、再チャレンジするようにする。
FUNCは`package-install'であることを前提としており、ARGSは
`package-install'に渡す引数。"
  (unless (package-installed-p (car args))
    (condition-case err
        (apply func args)
      (error (progn (package-refresh-contents)
                    (apply func args))))))

(defmacro with-init-utils (&rest body)
  "`init-utils--package-install-advice'を適用した状態でBODYを評価する."
  `(progn
     (advice-add #'package-install
                 :around #'init-utils--package-install-advice)
     ,@body
     (advice-remove #'package-install
                    #'init-utils--package-install-advice)))


;;;; feature にする ================================================
(provide 'init-utils)


;;; init-utils.el ends here
