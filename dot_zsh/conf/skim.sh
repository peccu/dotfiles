if type sk >/dev/null
then
    source <(sk --shell zsh)
    # activate RegExp mode with C-r
    export SKIM_CTRL_R_OPTS="--bind=ctrl-r:rotate-mode"
    # sort by score
    export SKIM_DEFAULT_OPTIONS="--tiebreak score,index"
fi
