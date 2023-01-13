# -*- coding:utf-8; mode:shell-script  -*-
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[ -f ~/.bash/.bash_completion ] && source ~/.bash/.bash_completion

# https://serverfault.com/a/831184
if [ -d ~/.bash/completion.d ]
then
  for bcfile in ~/.bash/completion.d/*
  do
    [ -f "$bcfile" ] && . $bcfile
  done
fi
