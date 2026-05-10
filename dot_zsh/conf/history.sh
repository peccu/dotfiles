# Disable /etc/zshrc_Apple_Terminal
export SHELL_SESSION_HISTORY=0
# share history
setopt share_history
# fcntl lock to prevent corruption on concurrent shell startup / interrupted writes
setopt hist_fcntl_lock
# timestamped entries — easier to recover if the file is truncated
setopt extended_history
export HISTSIZE=100000
export SAVEHIST=1000000
export HISTFILE=~/.zsh_history
