# Global user instructions

## Git staging

- Never run `git add -A`, `git add --all`, or `git add .` (nor equivalents like
  `git -C <path> add -A`, `cd <repo> && git add .`). Always stage only the
  specific files you created or modified, listing them explicitly:
  `git add <path> ...`.
- Before committing, review `git status` and add the intended files one by one.
  This avoids sweeping unrelated changes into a commit.
- Do not rely on the `block-git-add-all.sh` PreToolUse hook to enforce this —
  this environment is enterprise-managed and hooks may be disabled by managed
  settings. Follow the rule behaviorally regardless.

## 環境・ツール

- `jq` はインストール済み。シェルでの軽量な JSON 抽出・整形は
  `python3 -c ...` ではなく `jq` を第一選択にする。
  （スキルの `scripts/` 内で `#!/usr/bin/env python3` を使うのは
  リポジトリ規約に沿った意図的な選択なので、そちらは対象外。）

## 出力フォーマット

調査・コマンド実行・エージェント実行の結果を報告するときは、
途中経過の詳細と最終的な要点（サマリ）を明確に分離すること。

- 「ここから読めばよい」という要点セクションは、見出しの前後に
  水平線（---）を入れて視覚的に目立たせる
- 途中の調査ログと要点が地続きにならないよう、区切りを明示する
