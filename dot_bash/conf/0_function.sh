# -*- shell-script -*-
function exists(){
    type $1 >/dev/null 2>&1
}

# diff xlsx
# needs git-xlsx-textconv ( https://github.com/tokuhirom/git-xlsx-textconv )
# and delta ( https://github.com/dandavison/delta )
function diff-xlsx(){
    diff -u <(git-xlsx-textconv "$1") <(git-xlsx-textconv "$2") | delta
}

function decode-aws-authorization-message(){
    aws sts decode-authorization-message \
        --encoded-message $1 \
        | jq -r '.DecodedMessage' \
        | jq -rC . \
        | less -R
}

function jqcsv(){
    cat - \
        | jq -sr '.
        | (map(keys) | add | unique) as $cols
        | map(. as $row | $cols | map($row[.])) as $rows
        | $cols, $rows[]
        | @csv'
}

function jqflatten(){
    # https://stackoverflow.com/a/33290267
    cat - \
        | jq -r '.[]
| [
    leaf_paths as $path
    | {
        "key": $path | map(tostring) | join("_"),
        "value": getpath($path)
    }
  ]
| from_entries'
}

function n(){
    line_notify "$@"
}

function C(){
    # for linux 'xclip -in -selection clipboard'
    # alternative 'xsel -ib'
    # osx 'pbcopy'
    # Android 'termux-clipboard-set'
    # tmux buffer 'tmux loadb -'
    # WSL with script '#!/bin/sh echo "$(cat -)" | clip.exe'
    # why doesn't use directly clip.exe ...??
    # copy over container in ~/.local/bin/copy
    cat - \
        | tee >(
            # if in tmux, copy into tmux buffer too
            if [ -n "$TMUX" ]
            then
                cat - | tmux loadb -
            else
                cat - >/dev/null
            fi
        ) \
            | (
        # and copy to clipboard
        if exists clip.exe
        then
            cat - | clip.exe
        elif exists xclip
        then
            # does not tested.
            cat - | xclip -i
        elif exists xsel
        then
            # does not tested. xsel -o is output?
            cat - | xsel -i
        elif exists pbcopy
        then
            cat - | pbcopy
        else
            # fallback for container
            cat - > /clip
        fi
    )
}

function ewsl(){
    # launch emacs with specified directory as ~/.emacs.d
    basedir="$1"
    if [ -z "$basedir" ]
    then
        echo init directory does not specified so using ~/.emacs.d
        basedir=~/.emacs.d
    fi
    if [ $(emacs --version | grep 'GNU Emacs [1-9]' | awk '{print $3}' | cut -d. -f1) -ge 29 ]
    then
        # Emacs 29 or up can use --init-directory
        emacs --init-directory $basedir
    else
        HOME=$basedir/.. emacs -Q --eval '(setq user-emacs-directory "'$basedir'/")' -l $basedir/init.el
    fi
}

function t(){
    tmux attach-session $* || tmux $*
}

function ja(){
    echo ja
}

function nein(){
    echo nein
}

function tarpvcompress(){
    local dir=$1
    # https://www.tecmint.com/monitor-copy-backup-tar-progress-in-linux-using-pv-command/
    tar czf - $dir | (pv > $dir.tar.gz)
}

function tarpvextract(){
    local tar=$1
    # https://stackoverflow.com/a/67999872
    pv $tar | tar xz
}

function set-permissions-file-to-644(){
    find . -type f -print | xargs chmod 644
}

function set-permissions-file-to-755(){
    find . -type f -print | xargs chmod 755
}

function set-permissions-directory-to-755(){
    find . -type d -print | xargs chmod 755
}

function setup-permissions-for-ssh-dir(){
    # set correct permissions
    # cf. https://superuser.com/a/215506
    # for directories and files
    # cf. https://superuser.com/a/91938
    find ~/.ssh -type d -print | xargs chmod 755
    find ~/.ssh -type f -print | grep -e '\.pub$' | xargs chmod 644
    find ~/.ssh -type f -print | grep -ve '\.pub$' | xargs chmod 600
    chmod 700 ~/.ssh
    chmod 755 ~
}

function is_in_wslhost(){
    # defined in 0_env_local.sh
    exists hostname && [ "${WSLHOST_HOSTNAME}" = "$(hostname)" ]
}

function not_in_tmux(){
    [ -z "$TMUX" ]
}

function filter-branch-overwrite-git-author(){
    if [ $# -lt 3 ]
    then
        echo USAGE: filter-branch-overwrite-git-author "oldemail" "new name" "newemail"
        return 1
    fi
    oldemail="$1"
    shift
    newname="$1"
    shift
    newemail="$1"
    echo OLD_EMAIL="'$oldemail'"
    echo CORRECT_NAME="'$newname'"
    echo CORRECT_EMAIL="'$newemail'"

    # cf. https://stackoverflow.com/questions/750172/how-do-i-change-the-author-and-committer-name-email-for-multiple-commits/750182#750182
    git filter-branch --env-filter '
OLD_EMAIL="'$oldemail'"
CORRECT_NAME="'$newname'"
CORRECT_EMAIL="'$newemail'"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
}
