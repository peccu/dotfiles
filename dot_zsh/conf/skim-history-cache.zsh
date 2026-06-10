# skim-history-override.zsh
# Overrides skim-history-widget to remove the slow awk/sed dedup+color
# pipeline. Just pipes fc directly into sk for instant startup.
# Must be sourced after skim-key-bindings.zsh.

skim-history-widget() {
  local selected num ret
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
  local n=2
  [[ -o extended_history ]] && n=3

  selected=( $(fc -rl -i 1 | SKIM_DEFAULT_OPTIONS="$SKIM_DEFAULT_OPTIONS \
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
