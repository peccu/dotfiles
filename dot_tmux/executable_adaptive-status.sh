#!/usr/bin/env bash
# Switch tmux2k's left/right plugin lists based on client width.
# Wired up from ~/.tmux.conf via client-resized / client-attached hooks.
#
# Notes:
# - tmux2k's get_tmux_option treats an empty value as "unset" and falls back
#   to its built-in default plugin list. To express "no plugins on this side"
#   we run 2k.tmux with a placeholder, then overwrite that side ourselves.
# - status-right keeps the continuum_save.sh hook even when "empty" so that
#   tmux-continuum's periodic auto-save keeps firing.

# Serialize against ourselves — resize storms can fire the hook rapid-fire.
exec 200>/tmp/tmux-adaptive-status.${UID}.lock
flock -n 200 || exit 0

# Wait out any concurrent tmux2k rebuild (e.g. tpm at startup) so our
# set-option appends aren't interleaved with theirs.
for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -f "tmux2k/main.sh" >/dev/null 2>&1 || break
    sleep 0.3
done

width=$(tmux display-message -p '#{client_width}')
threshold=$(tmux show -gv @tmux2k-width-threshold 2>/dev/null)
left_wide=$(tmux show -gv @tmux2k-left-plugins-wide 2>/dev/null)
left_narrow=$(tmux show -gv @tmux2k-left-plugins-narrow 2>/dev/null)
right_wide=$(tmux show -gv @tmux2k-right-plugins-wide 2>/dev/null)
right_narrow=$(tmux show -gv @tmux2k-right-plugins-narrow 2>/dev/null)

: "${threshold:=100}"
: "${left_wide:=session cwd}"
: "${right_wide:=cpu ram battery weather time}"

if [ "$width" -lt "$threshold" ]; then
    mode="narrow"
    left="$left_narrow"
    right="$right_narrow"
else
    mode="wide"
    left="$left_wide"
    right="$right_wide"
fi

# No early-exit on @tmux2k-adaptive-applied == mode: a tmux.conf reload (or
# any other path that re-runs 2k.tmux) can rewrite status-left/right while the
# applied flag stays put, leaving the bar stuck on the wrong mode. flock above
# already debounces resize storms, so re-applying every time is safe and cheap.

# Use a harmless placeholder so tmux2k doesn't substitute its built-in default.
# We override these sides to empty afterwards.
tmux set -g @tmux2k-left-plugins  "${left:-session}"
tmux set -g @tmux2k-right-plugins "${right:-time}"

~/.tmux/plugins/tmux2k/2k.tmux >/dev/null 2>&1

# Preserve continuum's auto-save hook even when status-right is "empty".
continuum_hook='#(/home/casaos/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh)'

[ -z "$left" ]  && tmux set -g status-left ""
[ -z "$right" ] && tmux set -g status-right "$continuum_hook"

tmux set -g @tmux2k-adaptive-applied "$mode"
