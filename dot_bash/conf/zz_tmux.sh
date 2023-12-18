# -*- coding:utf-8; mode:shell-script  -*-
function __setup_tmux(){
    local MYTMP=tmux-$(id -u)
    if exists tmux && ls -l /tmp/ | grep $MYTMP | grep root > /dev/null
    then
        # tmux is installed and if tmpdir is owned by root
        sudo chown $(id -u):$(id -g) /tmp/$MYTMP/
        sudo chmod 700 /tmp/$MYTMP/
    fi
    # [ -z "$TMUX" ] && (echo not in tmux >&2) || (echo in tmux >&2)
    # [ "$TOOLTYPE" != "tool" ] && (echo not in toolcontainer >&2) || (echo in toolcontainer >&2)
    # [ ! -z "$WSL_DISTRO_NAME" ] && (echo on wsl >&2) || (echo not on wsl >&2)
    # need to detect not in container (in host WSL)
    if exists tmux && [ -z "$TMUX" ] && [ ! -z "$WSL_DISTRO_NAME" ]
    then
        # installed but not in there and on WSL Host
        # echo attach or start tmux session >&2
        tmux attach-session $* || tmux $*
    fi
}
__setup_tmux
