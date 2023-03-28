# _docker should be installed with docker-ce-cli
# check it via dpkg -L docker-ce-cli | grep completion
if [ "$(type -t _docker)" != "function" -a -f /usr/share/bash-completion/completions/docker ]
then
    source /usr/share/bash-completion/completions/docker
fi
complete -F _docker d
