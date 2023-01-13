# -*- shell-script -*-
# https://github.com/mooz/percol#zsh-history-search
# TODO needs support buildin command, function and alias (maybe need calls type)
function exists(){
    which $1 &> /dev/null 2>&1
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

function n(){
    line_notify "$@"
}

function C(){
    if exists clip.exe
    then
        cat - | clip.exe
    else
        cat - > /clip
    fi
}

function ewsl(){
    # launch emacs with specified directory as ~/.emacs.d
    basedir="$1"
    if [ -z "$basedir" ]
    then
        echo init directory does not specified so using ~/.emacs.d
        basedir=~/.emacs.d
    fi
    emacs -q --eval '(setq user-emacs-directory "'$basedir'/")' -l $basedir/init.el
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
