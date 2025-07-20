;;; -*- lexical-binding: t; coding: utf-8 -*-

;;;; デフォルトの文字コード ------------------------------------------
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-emacs-unix)

;;;; フォント --------------------------------------------------------
(set-face-attribute 'default nil
                    :family "HackGen Console NF" :height 100)
(set-face-attribute 'fixed-pitch nil
                    :inherit 'default)

;;;; modus-themes ----------------------------------------------------
(setopt
 ;; modus-operandi-tinted-palette-overrides '((bg-main     "#fff7fb")
 ;;                                           (bg-dim      "#ffe7ef")
 ;;                                           (bg-alt      "#ffddef")
 ;;                                           (bg-active   "#ffbbee")
 ;;                                           (bg-inactive "#ffe7ef"))

 custom-enabled-themes '(modus-operandi-tinted)
 )

;;;; バー ------------------------------------------------------------
(setopt ;bars
 menu-bar-mode nil ;メニューバーを非表示
 tool-bar-mode nil ;ツールバーを非表示
 scroll-bar-mode 'right ;スクロールバーは右側
 )

;;;; 背景透過 --------------------------------------------------------
;; (add-to-list 'default-frame-alist '(alpha . 50))


;;; early-init.el ends here
