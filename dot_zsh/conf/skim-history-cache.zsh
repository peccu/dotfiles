# skim-history-cache.zsh
# Speeds up C-r by pre-building the deduped/colorized history list in the
# background. Must be sourced after skim-key-bindings.zsh.
#
# Flow:
#   precmd  -> fc dump (sync, fast: reads RAM) -> awk|sed (async, &!)
#   C-r     -> sk < cache  (instant)

typeset -g _SKIM_HIST_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-history-skim.txt"
typeset -g _SKIM_HIST_CACHE_LAST=0

_skim_history_cache_build() {
  local ext=0
  [[ -o extended_history ]] && ext=1

  local tmpraw
  tmpraw=$(mktemp "${TMPDIR:-/tmp}/zsh-hist-XXXXXX") || return 1
  mkdir -p "${_SKIM_HIST_CACHE%/*}" 2>/dev/null

  # Dump in-memory history (fast: no file I/O, reads zsh history array)
  if (( ext )); then
    fc -rl -i 1 > "$tmpraw" 2>/dev/null
  else
    fc -rl 1    > "$tmpraw" 2>/dev/null
  fi
  [[ -s $tmpraw ]] || { rm -f "$tmpraw"; return 1; }

  # Dedup + colorize + multiline-escape in background
  local tmpout="${_SKIM_HIST_CACHE}.tmp"
  local c_idx=$'\033[2m' c_date=$'\033[32m' c_reset=$'\033[0m'
  {
    trap "rm -f '$tmpraw'" EXIT
    if (( ext )); then
      local today; today=$(date +%Y-%m-%d)
      awk -v c_idx="$c_idx" -v c_date="$c_date" -v c_reset="$c_reset" \
          -v today="$today" '
        {
          $1=$1
          cmd = $0
          sub(/^[ \t]*[0-9]+\**[ \t]+[^ \t]+[ \t]+[^ \t]+[ \t]+/, "", cmd)
          if (!seen[cmd]++) {
            time=$3; date=$2; idx=$1
            if (date == today)
              sub(date " " time "  ", c_date "today@" time c_reset "\t")
            else
              sub(date " " time "  ", c_date date c_reset "\t")
            sub(idx, c_idx idx c_reset)
            print
          }
        }' "$tmpraw"
    else
      awk -v c_idx="$c_idx" -v c_reset="$c_reset" '
        {
          $1=$1; cmd=$0
          sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd)
          if (!seen[cmd]++) {
            idx=$1
            sub(idx, c_idx idx c_reset)
            print
          }
        }' "$tmpraw"
    fi | sed 's/\\n/\\n\t/g' > "$tmpout" \
      && mv -f "$tmpout" "$_SKIM_HIST_CACHE"
  } &!
}

# Rebuild at most once per 5 s, only when the history file has changed
_skim_history_cache_precmd() {
  (( EPOCHSECONDS - _SKIM_HIST_CACHE_LAST < 5 )) && return 0
  [[ $HISTFILE -nt $_SKIM_HIST_CACHE ]] || return 0
  _SKIM_HIST_CACHE_LAST=$EPOCHSECONDS
  _skim_history_cache_build
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _skim_history_cache_precmd

# Preserve the original widget defined in skim-key-bindings.zsh
(( ${+functions[skim-history-widget]} )) &&
  functions[_skim_history_widget_orig]=${functions[skim-history-widget]}

# Override: instant cache read when available; original slow path on first run
skim-history-widget() {
  local selected num ret

  if [[ ! -f $_SKIM_HIST_CACHE ]]; then
    # No cache yet: trigger a build and fall back to the original widget
    _skim_history_cache_build
    if (( ${+functions[_skim_history_widget_orig]} )); then
      _skim_history_widget_orig
      return $?
    fi
    return 0
  fi

  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
  local n=3
  [[ -o extended_history ]] || n=2

  local sk_opts="$SKIM_DEFAULT_OPTIONS \
    -n${n}..,.. \
    --bind=ctrl-r:toggle-sort \
    $SKIM_CTRL_R_OPTS \
    --query=${(qqq)LBUFFER} \
    --no-multi \
    --ansi \
    --tabstop=20 \
    --multiline"

  selected=( $(SKIM_DEFAULT_OPTIONS="$sk_opts" sk < "$_SKIM_HIST_CACHE") )
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
