#!/bin/bash
# Claude Code notification popup helper
# Usage: notify-popup.sh <message_emoji> <message_text> <session:window.pane>

EMOJI="$1"
MESSAGE="$2"
TARGET="$3"

echo "$EMOJI $MESSAGE"
echo "📍 $TARGET"
echo "(Enter:移動 / Esc:閉じる / 3秒で自動閉じ)"

if read -s -n 1 -t 3 key && [ -z "$key" ]; then
  # 現在のペインを記録してから移動
  CURRENT=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
  echo "$CURRENT" > ~/.claude/scripts/.pane-stash
  tmux switch-client -t "$TARGET" 2>/dev/null
fi
