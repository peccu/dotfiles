#!/bin/bash
# Stashしたペインに戻る
STASH_FILE=~/.claude/scripts/.pane-stash

if [ -f "$STASH_FILE" ]; then
  TARGET=$(cat "$STASH_FILE")
  rm "$STASH_FILE"
  tmux switch-client -t "$TARGET" 2>/dev/null
else
  tmux display-message "戻り先がありません"
fi
