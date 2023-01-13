# -*- coding:utf-8; mode:shell-script  -*-
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
# set in the container. in host path should be so slow
export CARGO_HOME=/tmp/.cargo
