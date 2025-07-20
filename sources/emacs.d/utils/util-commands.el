;;; util-commands.el --- GNU Emacs settings. -*- lexical-binding: t; coding: utf-8 -*-

;; Author: yam-k
;; Version: 0.1.0
;; Keywords: init


;;; Commentary:

;; なんかいろいろ。
;;
;; * util-commands-select-previous-window
;; ウィンドウを逆順に巡回する。
;;
;; * util-commands-toggle-fringe
;; fringeを最小化したり戻したり。
;;
;; * util-commands-toggle-tab-bar
;; tab-barを表示したり非表示にしたり。
;;
;; * util-commands-raise-volume
;; 音量を上げる。
;;
;; * util-commands-lower-volume
;; 音量を下げる。
;;
;; * util-commands-toggle-mute
;; 消音したり戻したり。


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

;;;; ウィンドウを逆順に巡回する ====================================
;; (defun util-commands-select-previous-window ()
;;   "一つ前のウィンドウをフォーカスする."
;;   (interactive)
;;   (other-window -1))


;;;; 表示のトグル ==================================================
(defun util-commands-toggle-fringe ()
  "編集領域両側のfringeを最小化(size=1)したり戻したり(size=8)."
  (interactive)
  (cond ((null fringe-mode) (setopt fringe-mode 1))
        ((= fringe-mode 1) (setopt fringe-mode 8))
        (t (setopt fringe-mode 1))))

(defun util-commands-toggle-tab-bar ()
  "タブバーの表示をトグルする."
  (interactive)
  (cond ((null tab-bar-show) (setopt tab-bar-show t))
        (t (setopt tab-bar-show nil))))


;;;; pulseaudio-utilsのコントロール ================================
;; (defun util-commands-raise-volume ()
;;   "システムの音量を上げる."
;;   (interactive)
;;   (call-process "pactl" nil nil nil
;;                 "set-sink-volume" "@DEFAULT_SINK@" "+5%"))

;; (defun util-commands-lower-volume ()
;;   "システムの音量を下げる."
;;   (interactive)
;;   (call-process "pactl" nil nil nil
;;                 "set-sink-volume" "@DEFAULT_SINK@" "-5%"))

;; (defun util-commands-toggle-mute ()
;;   "システム音量のミュートをトグルする."
;;   (interactive)
;;   (call-process "pactl" nil nil nil
;;                 "set-sink-mute" "@DEFAULT_SINK@" "toggle"))


;;;; feature として登録 ============================================
(provide 'util-commands)


;;; util-commands.el ends here
