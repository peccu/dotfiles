# -*- shell-script -*-
function drop-escape-sequence(){
    cat - \
        |sed -ur "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}
