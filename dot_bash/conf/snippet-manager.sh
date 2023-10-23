#!/bin/bash

export SNIP_DIR=~/.local/share/snip

# snippet file format
# first line is description
# the lasting lines are the snippet

function snip(){
    (
        cd $SNIP_DIR
        for i in snip*
        do
            echo -n "$i,"
            head -n 1 -q $i
        done \
            | fzf \
                  --delimiter , \
                  --with-nth 2.. \
                  --preview 'tail -n +2 {1} | bat -n --color=always --file-name {1}' \
                  --preview-window up,60% \
                  --info inline \
                  --bind 'enter:become(tail -n +2 {1} | copy)'
    )
}

function snip-add(){
    (
        if [ -z "$EDITOR" ]
        then
            EDITOR='vi'
        fi
        _snip-checkdirty || return 1
        read -ep "Description: " desc
        read -ep "Extension: " ext
        read -ep "Snippet (leave empty to open EDITOR): " code
        tmpfile=$(mktemp -t snip.XXXXXX --suffix=.$ext)
        if [ -z "$code" ]
        then
            $EDITOR $tmpfile
        else
            printf "$code\n" > $tmpfile
        fi
        echo "snip syncing"
        _snip-sync
        cd $SNIP_DIR
        nextnumber=$((1+ $(ls snip* | cut -d. -f1 | cut -d_ -f2 | sort -n | tail -1)))
        cat <(echo "$desc") $tmpfile > snip_$nextnumber.$ext
        rm $tmpfile
        git add snip_$nextnumber.$ext
        git commit -m "add snippet: $desc"
        git push origin
    )
}
alias sa=snip-add

function _snip-checkdirty(){
    (
        cd $SNIP_DIR
        git status -s | grep snip \
            && (
            echo
            echo directory is dirty. please check
            return 1
        )
        return 0
    )
}

function _snip-sync(){
    (
        cd $SNIP_DIR
        git fetch origin
        git reset --hard origin/main > /dev/null
    )
}
