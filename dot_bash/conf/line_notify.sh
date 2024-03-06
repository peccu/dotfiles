# -*- shell-script -*-

# TODO supports stdin
# ref. https://developers.line.biz/en/docs/messaging-api/sticker-list/#sticker-definitions

function line_notify(){
    local token=$LINE_NOTIFY_TOKEN
    local message="$@"
    if [ -z "$message" ]
    then
        message="Notification!"
    fi
    echo Sending notification to LINE
    curl -X POST \
         -H "Authorization: Bearer ${token}" \
         -F "message=${message}" \
         https://notify-api.line.me/api/notify
    echo
    echo Done.
}

function line_notify_sticker(){
    local token=$LINE_NOTIFY_TOKEN
    local message="$@"
    # https://developers.line.biz/en/docs/messaging-api/sticker-list/#sticker-definitions
    local stickerPackageId=789
    local stickerId=10871
    if [ -z "$message" ]
    then
        message="Notification!"
    fi
    echo Sending notification to LINE
    curl -X POST \
         -H "Authorization: Bearer ${token}" \
         -F "message=${message}" \
         -F "stickerPackageId=${stickerPackageId}" \
         -F "stickerId=${stickerId}" \
         https://notify-api.line.me/api/notify
    echo
    echo Done.
}

function line_notify_image(){
    local token=$LINE_NOTIFY_TOKEN
    local jpegFile=$1
    shift
    if [ ! -f "$jpegFile" ]
    then
        echo "image file not found: ${jpegFile}"
        return
    fi
    local message="$@"
    if [ -z "$message" ]
    then
        message="Notification!"
    fi
    echo Sending notification to LINE
    echo curl -X POST \
         -H "Authorization: Bearer ${token}" \
         -F "message=${message}" \
         -F "imageFile=@${jpegFile}" \
         https://notify-api.line.me/api/notify
    echo
    echo Done.
}

# in 0_function.sh
# function n(){ line_notify "$@" }
