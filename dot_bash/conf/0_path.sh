# -*- shell-script -*-
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
[ -d ~/.local/bin ] && export PATH=$HOME/.local/bin:$PATH
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
