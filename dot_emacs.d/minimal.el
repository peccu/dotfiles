;; minimal.el — EDITOR 用の最小設定
;; Usage: emacs -Q -nw -l ~/.emacs.d/minimal.el
;; Managed by chezmoi (not by .emacs.d git repo)

;; ダーク背景モード（conflict 表示等の face が読めるようになる）
(setq frame-background-mode 'dark)
(mapc 'frame-set-background-mode (frame-list))

;; dired の directory 色を見やすく
(require 'dired)
(set-face-foreground 'dired-directory "#5C7AFF")
