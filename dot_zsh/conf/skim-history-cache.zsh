# skim-history-override.zsh
# Overrides skim-history-widget to remove the slow awk/sed dedup+color
# pipeline. Just pipes fc directly into sk for instant startup.
#
# Also drops the `-i` flag: `fc -rl -i` formats an ISO timestamp per history
# entry, which is a per-line syscall that balloons to tens of seconds under
# high system load (measured 60-100s with ~11k entries). Without `-i` the
# same listing is ~20ms. Trade-off: no timestamp column in the picker, only
# the event index and the command (matched via -n2..).
#
# Must be sourced after skim-key-bindings.zsh.

skim-history-widget() {
  local selected num ret
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
  local n=2

  selected=( $(fc -rl 1 | SKIM_DEFAULT_OPTIONS="$SKIM_DEFAULT_OPTIONS \
    -n${n}..,.. \
    --bind=ctrl-r:toggle-sort \
    $SKIM_CTRL_R_OPTS \
    --query=${(qqq)LBUFFER} \
    --no-multi" sk) )
  ret=$?

  if [[ -n "$selected" ]]; then
    num=$selected[1]
    [[ -n "$num" ]] && zle vi-fetch-history -n $num
  fi
  zle reset-prompt
  tput cnorm
  return $ret
}
zle -N skim-history-widget
