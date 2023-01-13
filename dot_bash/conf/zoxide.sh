# -*- coding:utf-8; mode:shell-script  -*-
if exists zoxide
then
    # print the matched directory before navigationg to it
    export _ZO_ECHO=1
    eval "$(zoxide init bash)"
    alias j=z
    # zi interactive selection
    # zq query only not cd
    # za add path
    # zr remove path
fi
