#!/bin/bash
# Claude Code notification hook
# Usage: notify-hook.sh <emoji> <message>
# Example: notify-hook.sh '✅' '入力待ちです'

EMOJI="$1"
MESSAGE="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INFO=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
ACTIVE=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)

printf '\a'

if [ "$INFO" = "$ACTIVE" ]; then
  # 同じペインにいるのでポップアップ不要
  tmux display-message "🤖 Claude Code: $MESSAGE" 2>/dev/null
else
  tmux display-message "🤖 Claude Code: $MESSAGE" 2>/dev/null
  tmux display-popup -w 45 -h 6 -d '#{pane_current_path}' -E \
    "$SCRIPT_DIR/notify-popup.sh '$EMOJI' '$MESSAGE' '$INFO'" 2>/dev/null &
fi
