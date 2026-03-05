# setup zoxide (autojump alt)
if exists zoxide
then
    # print the matched directory before navigationg to it
    export _ZO_ECHO=1
    # needs compinit
    # setup j and ji
    eval "$(zoxide init zsh --cmd j)"
fi
