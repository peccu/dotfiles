# -*- shell-script -*-
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
[ -d ~/.local/bin ] && export PATH=$HOME/.local/bin:$PATH
# nix per-user profile (also added by nix's own profile scripts; dedup handles overlap)
[ -d "$HOME/.nix-profile/bin" ] && export PATH="$HOME/.nix-profile/bin:$PATH"
# Google Cloud SDK — GCLOUD_MY_HOME is defined in ~/.bash/conf/0_env_local.sh.
# Shell-agnostic replacement for gcloud's path.zsh.inc so bash gets it too.
[ -n "$GCLOUD_MY_HOME" ] && [ -d "$GCLOUD_MY_HOME/bin" ] && export PATH="$GCLOUD_MY_HOME/bin:$PATH"
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
# psql, pg_dump
[ -d /opt/homebrew/opt/libpq/bin ] && export PATH=/opt/homebrew/opt/libpq/bin:$PATH
# Python
[ -d ~/Library/Python/3.9/bin ] && export PATH="$PATH:$HOME/Library/Python/3.9/bin"

[ -d /opt/homebrew/opt/ruby/bin ] && export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# [ -d /opt/homebrew/opt/ruby@3.1/bin ] && export PATH="/opt/homebrew/opt/ruby@3.1/bin:$PATH"
[ -d /opt/homebrew/opt/ruby@3.4/bin ] && export PATH="/opt/homebrew/opt/ruby@3.4/bin:$PATH"
# prefer bash in homebrew for tmux2k
[ -d /opt/homebrew/bin ] && export PATH="/opt/homebrew/bin:$PATH"
