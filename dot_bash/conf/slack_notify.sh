# -*- shell-script -*-

function slack_notify(){
    local webhook=$SLACK_BOT_WEBHOOK_URL
    if [ -z "$webhook" ]
    then
        echo "SLACK_BOT_WEBHOOK_URL is not set."
        return 1
    fi

    local url="https://google.com"
    while getopts "u:" opt; do
        case $opt in
            u)
                url=$OPTARG
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    local message="$@"
    if [ -z "$message" ]
    then
        message="Notification!"
    fi
    echo Sending notification to Slack
    curl -d '{"message":"'"$message"'", "url":"'"$url"'"}' \
        $webhook
    echo
    echo Done.
}
