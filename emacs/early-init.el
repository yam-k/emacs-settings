;;; early-init.el --- GNU Emacs settings. -*- lexical-binding: t; coding: utf-8 -*-

;; Author: yam-k
;; URL: https://github.com/yam-k/settings
;; Version: 0.1.0
;; Keywords: init


;;; Commentary:

;; GNU Emacs の表示前にやっておきたい見た目の設定。
;; exwm の起動時にデフォルトの見た目が表示されるのを避ける。


;;; license:

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

;;;; フォント --------------------------------------------------------
(face-spec-set 'default '((t :font "HackGen Console NF"
                             :height 100)))
(face-spec-set 'fixed-pitch '((t :inherit default)))

;;;; modus-themes ----------------------------------------------------
(setopt
 modus-themes-operandi-color-overrides '((bg-main . "#fff7fb")
                                         (bg-dim . "#ffe7ef")
                                         (bg-alt . "#ffddef")
                                         (bg-active . "#ffbbee")
                                         (bg-inactive . "#ffe7ef"))
 modus-themes-box-buttons '(flat accented)
 ;; modus-themes-syntax '(alt-syntax green-strings yellow-comments)
 ;; modus-themes-mode-line '(borderless accented)
 ;; modus-themes-tabs-accented t
 ;; modus-themes-completions '((matches . (background intense))
 ;;                            (selection . (accented intense))
 ;;                            (popup .  (accented intense)))
 ;; modus-themes-fringes 'intense
 ;; modus-themes-hl-line '(accented)
 ;; modus-themes-intense-mouseovers t
 ;; modus-themes-markup '(intense)
 ;; modus-themes-paren-match '(intense)
 ;; modus-themes-region '(accented)

 custom-enabled-themes '(modus-operandi)
 )

;;;; バー ------------------------------------------------------------
(setopt ;bars
 ;; custom-enabled-themes '(adwaita) ;テーマ

 menu-bar-mode nil ;メニューバーを非表示
 tool-bar-mode nil ;ツールバーを非表示
 scroll-bar-mode 'right ;スクロールバーは右側
 )

;;;; 背景透過 --------------------------------------------------------
;; (add-to-list 'default-frame-alist '(alpha . 50))


;;; early-init.el ends here
