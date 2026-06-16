# Global user instructions

## Git staging

- Never run `git add -A`, `git add --all`, or `git add .` (nor equivalents like
  `git -C <path> add -A`, `cd <repo> && git add .`). Always stage only the
  specific files you created or modified, listing them explicitly:
  `git add <path> ...`.
- Before committing, review `git status` and add the intended files one by one.
  This avoids sweeping unrelated changes into a commit.
- Do not rely on the `block-git-add-all.sh` PreToolUse hook to enforce this —
  this environment is enterprise-managed and hooks may be disabled by managed
  settings. Follow the rule behaviorally regardless.
