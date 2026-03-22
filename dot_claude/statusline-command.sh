#!/bin/sh
# Claude Code status line - multi-line dashboard
# Lines: 1) Cost  2) Tokens  3) Rate Limits  4) Session  5) tmux

input=$(cat)

# ── Helper: format milliseconds to human-readable ──
fmt_ms() {
  ms="$1"
  [ -z "$ms" ] && return
  sec=$((ms / 1000))
  if [ "$sec" -ge 3600 ]; then
    printf "%dh%02dm" $((sec / 3600)) $(( (sec % 3600) / 60 ))
  elif [ "$sec" -ge 60 ]; then
    printf "%dm%02ds" $((sec / 60)) $((sec % 60))
  else
    printf "%ds" "$sec"
  fi
}

# ── Helper: format token count (e.g. 125400 -> 125.4k) ──
fmt_tok() {
  n="$1"
  [ -z "$n" ] || [ "$n" = "null" ] && { printf "-"; return; }
  if [ "$n" -ge 1000000 ]; then
    printf "%.1fM" "$(echo "$n" | awk '{printf "%.1f", $1/1000000}')"
  elif [ "$n" -ge 1000 ]; then
    printf "%.1fk" "$(echo "$n" | awk '{printf "%.1f", $1/1000}')"
  else
    printf "%d" "$n"
  fi
}

# ── Helper: format unix epoch to HH:MM ──
fmt_epoch() {
  epoch="$1"
  [ -z "$epoch" ] || [ "$epoch" = "null" ] && return
  date -r "$epoch" +%H:%M 2>/dev/null || date -d "@$epoch" +%H:%M 2>/dev/null
}

# ── Extract directory and git info for line 1 ──
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
home="$HOME"
short_dir="${cwd/#$home/\~}"

git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

user_name=$(whoami)
tmux_pane="${TMUX_PANE:-}"

# ── Extract all data at once with a single jq call ──
eval "$(echo "$input" | jq -r '
  def v: . // "" | tostring | @sh;
  "cost_usd=\(.cost.total_cost_usd | v)",
  "duration_ms=\(.cost.total_duration_ms | v)",
  "api_ms=\(.cost.total_api_duration_ms | v)",
  "lines_add=\(.cost.total_lines_added | v)",
  "lines_del=\(.cost.total_lines_removed | v)",
  "ctx_pct=\(.context_window.used_percentage | v)",
  "ctx_size=\(.context_window.context_window_size | v)",
  "in_tok=\(.context_window.total_input_tokens | v)",
  "out_tok=\(.context_window.total_output_tokens | v)",
  "cache_read=\(.context_window.current_usage.cache_read_input_tokens | v)",
  "cache_write=\(.context_window.current_usage.cache_creation_input_tokens | v)",
  "rl5_pct=\(.rate_limits.five_hour.used_percentage | v)",
  "rl5_reset=\(.rate_limits.five_hour.resets_at | v)",
  "rl7_pct=\(.rate_limits.seven_day.used_percentage | v)",
  "rl7_reset=\(.rate_limits.seven_day.resets_at | v)",
  "model=\(.model.display_name | v)",
  "model_id=\(.model.id | v)",
  "session_id=\(.session_id | v)",
  "version=\(.version | v)",
  "vim_mode=\(.vim.mode | v)",
  "agent_name=\(.agent.name | v)"
' 2>/dev/null)"

# ── Colors ──
C_RESET="\033[0m"
C_LABEL="\033[2m"        # dim
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_CYAN="\033[36m"
C_MAGENTA="\033[35m"
C_RED="\033[31m"
C_BLUE="\033[34m"
C_BOLD="\033[1m"

# ── Helper: colorize percentage (green < 50, yellow < 80, red >= 80) ──
color_pct() {
  pct="$1"
  [ -z "$pct" ] && { printf "${C_LABEL}-${C_RESET}"; return; }
  int_pct=$(printf "%.0f" "$pct" 2>/dev/null || echo 0)
  if [ "$int_pct" -ge 80 ]; then
    printf "${C_RED}%s%%${C_RESET}" "$pct"
  elif [ "$int_pct" -ge 50 ]; then
    printf "${C_YELLOW}%s%%${C_RESET}" "$pct"
  else
    printf "${C_GREEN}%s%%${C_RESET}" "$pct"
  fi
}

# ═══════════════════════════════════════════════════
# Line 1: Directory / Git / User / Model / Context
# ═══════════════════════════════════════════════════
printf "${C_CYAN}%s${C_RESET}" "$short_dir"
[ -n "$git_branch" ] && printf " ${C_YELLOW}(%s)${C_RESET}" "$git_branch"
if [ -n "$tmux_pane" ]; then
  printf " ${C_GREEN}%s@%s${C_RESET}" "$user_name" "$tmux_pane"
else
  printf " ${C_GREEN}%s${C_RESET}" "$user_name"
fi
[ -n "$model" ] && printf " ${C_MAGENTA}%s${C_RESET}" "$model"
[ -n "$ctx_pct" ] && printf " ${C_LABEL}ctx:%s%%${C_RESET}" "$ctx_pct"
printf "\n"

# ═══════════════════════════════════════════════════
# Line 2: Cost & Performance
# ═══════════════════════════════════════════════════
printf "${C_LABEL}Cost:${C_RESET} "
if [ -n "$cost_usd" ]; then
  printf "${C_GREEN}\$%s${C_RESET}" "$cost_usd"
else
  printf "${C_LABEL}-${C_RESET}"
fi
printf "${C_LABEL} | Elapsed:${C_RESET} %s" "$(fmt_ms "$duration_ms")"
printf "${C_LABEL} | API:${C_RESET} %s" "$(fmt_ms "$api_ms")"
if [ -n "$lines_add" ] || [ -n "$lines_del" ]; then
  printf "${C_LABEL} | Lines:${C_RESET} ${C_GREEN}+%s${C_RESET}/${C_RED}-%s${C_RESET}" "${lines_add:-0}" "${lines_del:-0}"
fi
printf "\n"

# ═══════════════════════════════════════════════════
# Line 2: Token / Context Window
# ═══════════════════════════════════════════════════
printf "${C_LABEL}Context:${C_RESET} "
color_pct "$ctx_pct"
if [ -n "$ctx_size" ]; then
  printf "${C_LABEL}/%s${C_RESET}" "$(fmt_tok "$ctx_size")"
fi
printf "${C_LABEL} | In:${C_RESET} %s" "$(fmt_tok "$in_tok")"
printf "${C_LABEL} | Out:${C_RESET} %s" "$(fmt_tok "$out_tok")"
if [ -n "$cache_read" ] && [ "$cache_read" != "" ]; then
  printf "${C_LABEL} | Cache R:${C_RESET} %s" "$(fmt_tok "$cache_read")"
fi
if [ -n "$cache_write" ] && [ "$cache_write" != "" ]; then
  printf "${C_LABEL} / W:${C_RESET} %s" "$(fmt_tok "$cache_write")"
fi
printf "\n"

# ═══════════════════════════════════════════════════
# Line 3: Rate Limits
# ═══════════════════════════════════════════════════
printf "${C_LABEL}Rate:${C_RESET} "
if [ -n "$rl5_pct" ]; then
  printf "${C_LABEL}5h:${C_RESET} "
  color_pct "$rl5_pct"
  if [ -n "$rl5_reset" ] && [ "$rl5_reset" != "" ]; then
    printf "${C_LABEL}(~%s)${C_RESET}" "$(fmt_epoch "$rl5_reset")"
  fi
else
  printf "${C_LABEL}5h: -${C_RESET}"
fi
printf "${C_LABEL} | ${C_RESET}"
if [ -n "$rl7_pct" ]; then
  printf "${C_LABEL}7d:${C_RESET} "
  color_pct "$rl7_pct"
  if [ -n "$rl7_reset" ] && [ "$rl7_reset" != "" ]; then
    printf "${C_LABEL}(~%s)${C_RESET}" "$(fmt_epoch "$rl7_reset")"
  fi
else
  printf "${C_LABEL}7d: -${C_RESET}"
fi
printf "\n"

# ═══════════════════════════════════════════════════
# Line 4: Session & Other
# ═══════════════════════════════════════════════════
printf "${C_LABEL}Session:${C_RESET} "
[ -n "$model" ] && printf "${C_MAGENTA}%s${C_RESET}" "$model"
[ -n "$model_id" ] && printf "${C_LABEL}(%s)${C_RESET}" "$model_id"
[ -n "$version" ] && printf "${C_LABEL} | v%s${C_RESET}" "$version"
if [ -n "$session_id" ]; then
  short_sid=$(echo "$session_id" | cut -c1-8)
  printf "${C_LABEL} | sid:%s${C_RESET}" "$short_sid"
fi
[ -n "$vim_mode" ] && printf " ${C_CYAN}[%s]${C_RESET}" "$vim_mode"
[ -n "$agent_name" ] && printf " ${C_BLUE}@%s${C_RESET}" "$agent_name"
printf "\n"

# ═══════════════════════════════════════════════════
# Line 5: tmux info
# ═══════════════════════════════════════════════════
if command -v tmux >/dev/null 2>&1 && [ -n "$TMUX" ]; then
  tmux_session=$(tmux display-message -p '#S' 2>/dev/null)
  tmux_window=$(tmux display-message -p '#I:#W' 2>/dev/null)
  tmux_pane=$(tmux display-message -p '#P' 2>/dev/null)
  tmux_pane_count=$(tmux list-panes 2>/dev/null | wc -l | tr -d ' ')
  tmux_win_count=$(tmux list-windows 2>/dev/null | wc -l | tr -d ' ')

  printf "${C_LABEL}tmux:${C_RESET} "
  printf "${C_YELLOW}%s${C_RESET}" "$tmux_session"
  printf "${C_LABEL} | W:${C_RESET}${C_CYAN}%s${C_RESET}${C_LABEL}(%sw)${C_RESET}" "$tmux_window" "$tmux_win_count"
  printf "${C_LABEL} | P:${C_RESET}${C_GREEN}%s${C_RESET}${C_LABEL}(%sp)${C_RESET}" "$tmux_pane" "$tmux_pane_count"
  printf "\n"
fi
