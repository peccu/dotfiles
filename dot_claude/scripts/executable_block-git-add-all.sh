#!/usr/bin/env bash
# PreToolUse(Bash) hook: block `git add` invocations that stage everything.
#
# The user's workflow is to stage ONLY the specific files they created or
# modified — never the whole working tree. So `git add -A`, `git add --all`,
# and `git add .` (bare `.` / `./` / `:/` pathspec) are denied here.
#
# Detection tokenizes each command segment and walks it like git itself:
#   [VAR=val ...] git [global-opts...] add [args...]
# so forms with global options are also caught, e.g.
#   git -C path/to/repo add -A
#   git -c user.name=x --git-dir=.git add .
#   cd path && git add -A        (segments split on ; & |)
#
# Reads the Claude Code hook payload on stdin and, when a forbidden form is
# found, emits a PreToolUse deny decision as JSON. Otherwise stays silent
# (exit 0) so the command proceeds to the normal permission flow.
set -euo pipefail
set -f  # no globbing during word-splitting / here-strings

cmd=$(jq -r '.tool_input.command // ""')

deny() {
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git add -A / --all / . （全ステージング）は禁止されています。作成・変更したファイルだけを個別に指定してください: git add <path> ..."}}'
  exit 0
}

# True (0) if an `add` argument means "stage everything".
forbidden_arg() {
  case "$1" in
    .|./|:/)       return 0 ;;  # whole-tree pathspecs
    --all|--all=*) return 0 ;;
    --*)           return 1 ;;  # other long flags are fine
    -*A*)          return 0 ;;  # short-flag bundle containing -A (-A, -Av, -vA)
    *)             return 1 ;;
  esac
}

while IFS= read -r seg; do
  read -ra toks <<<"$seg"
  n=${#toks[@]}
  i=0

  # Skip leading `VAR=value` environment assignments.
  while [ "$i" -lt "$n" ]; do
    case "${toks[$i]}" in
      [A-Za-z_]*=*) i=$((i + 1)) ;;
      *) break ;;
    esac
  done

  # The command must be `git`.
  { [ "$i" -lt "$n" ] && [ "${toks[$i]}" = "git" ]; } || continue
  i=$((i + 1))

  # Skip git global options (and the argument of those that take one).
  while [ "$i" -lt "$n" ]; do
    case "${toks[$i]}" in
      -C|-c|--git-dir|--work-tree|--namespace|--super-prefix)
        i=$((i + 2)) ;;          # option + its separate argument
      --*) i=$((i + 1)) ;;       # =form / valueless long option
      -*)  i=$((i + 1)) ;;       # short option(s), e.g. -p -P
      *)   break ;;              # reached the subcommand
    esac
  done

  # Subcommand must be `add`.
  { [ "$i" -lt "$n" ] && [ "${toks[$i]}" = "add" ]; } || continue
  i=$((i + 1))

  # Inspect the arguments to `add`.
  while [ "$i" -lt "$n" ]; do
    forbidden_arg "${toks[$i]}" && deny
    i=$((i + 1))
  done
done < <(printf '%s\n' "$cmd" | tr ';&|' '\n')

exit 0
