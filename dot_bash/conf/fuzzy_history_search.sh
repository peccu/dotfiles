# -*- coding:utf-8; mode:shell-script  -*-
if [[ ":$SHELLOPTS:" =~ :(vi|emacs): ]]; then

    if exists sk || exists percol || exists peco ; then
        function percol_select_history(){
            local tac
            tac=$(exists gtac && echo gtac || (exists tac && echo tac || (echo tail -r)))
            local filter
            filter=$(exists sk && echo sk --layout=reverse --no-sort \
                             || ( exists percol && echo percol \
                                          || ( exists peco && echo peco) ) )
            if [ -z "$READLINE_LINE" ]
            then
                output=$(fc -l -n 1 | eval $tac | $filter)
            else
                output=$(fc -l -n 1 | eval $tac | $filter --query "$READLINE_LINE")
            fi
            READLINE_LINE=${output#*$'\t '}
            if [ -z "$READLINE_POINT" ]; then
                echo "$READLINE_LINE"
            else
                READLINE_POINT=${#READLINE_LINE}
            fi
        }
        bind -x '"\C-r": percol_select_history'
    fi
fi
