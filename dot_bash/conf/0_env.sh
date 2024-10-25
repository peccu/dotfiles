# -*- shell-script -*-
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color
export EDITOR='_editor () { emacs -Q -nw "$@"|| zile "$@"|| nano "$@" || vi "$@"; } ; _editor'
# needs git-credential-manager github login
export GCM_CREDENTIAL_STORE=plaintext
