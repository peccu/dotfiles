# -*- coding:utf-8; mode:shell-script  -*-
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=
export HISTFILESIZE=
# date format
export HISTTIMEFORMAT="%F %T "
# export HISTTIMEFORMAT="%y/%m/%d-%T "

# This will be overwrite by zoxide (unshift __zoxide_hook)
# export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
# history -a : append immediately
# history -c : clear current session history
# history -r : read history from file
export PROMPT_COMMAND="history -a; history -c; history -r"
