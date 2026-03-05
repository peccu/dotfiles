#!/bin/sh
# Claude Code status line - inspired by p10k segments: dir, vcs, context, model

input=$(cat)

# Extract data from JSON input
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten the directory: replace $HOME with ~
home="$HOME"
short_dir="${cwd/#$home/\~}"

# Git branch (skip optional locks to avoid blocking)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# User and hostname
user=$(whoami)
host=$(hostname -s)

# Build status line with ANSI colors
# Colors: bold cyan for dir, yellow for git, green for user@host, magenta for model, dim for context
printf "\033[36m%s\033[0m" "$short_dir"

if [ -n "$git_branch" ]; then
  printf " \033[33m(%s)\033[0m" "$git_branch"
fi

printf " \033[32m%s@%s\033[0m" "$user" "$host"

if [ -n "$model" ]; then
  printf " \033[35m%s\033[0m" "$model"
fi

if [ -n "$used_pct" ]; then
  printf " \033[2mctx:%s%%\033[0m" "$used_pct"
fi

printf "\n"
