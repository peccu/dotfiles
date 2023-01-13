# -*- coding:utf-8; mode:shell-script  -*-
# for dockerd in wsl, start dockerd standalone without systemd
if exists dockerd
then
    # https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9
    # https://github.com/bowmanjd/docker-wsl/blob/main/docker-service.sh
    DOCKER_DISTRO="Ubuntu-20.04"
    DOCKER_DIR=/mnt/wsl/shared-docker
    DOCKER_SOCK="$DOCKER_DIR/docker.sock"
    export DOCKER_HOST="unix://$DOCKER_SOCK"
    WSL=/mnt/c/Windows/System32/wsl.exe
    if [ ! -S "$DOCKER_SOCK" -a -x $WSL ]; then
        mkdir -pm o=,ug=rwx "$DOCKER_DIR"
        chgrp docker "$DOCKER_DIR"
        $WSL -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
    fi
fi
