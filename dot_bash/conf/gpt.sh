# -*- shell-script -*-

################################################################
# from
# https://github.com/0xacx/chatGPT-shell-cli
# and it is in ~/.local/bin/chatgpt
_gpt__escape() {
    echo "$1" | jq -Rrs 'tojson[1:-1]'
}

# build user chat message function for /chat/completions (gpt models)
# builds chat message before request,
# $1 should be the escaped request prompt,
# it extends $chat_message
_gpt__build_user_chat_message() {
    local escaped_request_prompt="$1"
    if [ -z "$chat_message" ]; then
        chat_message="{\"role\": \"user\", \"content\": \"$escaped_request_prompt\"}"
    else
        chat_message="$chat_message, {\"role\": \"user\", \"content\": \"$escaped_request_prompt\"}"
    fi
}

# adds the assistant response to the message in (chatml) format
# for /chat/completions (gpt models)
# keeps messages length under max token limit
# * $1 should be the escaped response data
# * it extends and potentially shrinks $chat_message
_gpt__add_assistant_response_to_chat_message() {
    local escaped_response_data="$1"
    # add response to chat context as answer
    chat_message="$chat_message, {\"role\": \"assistant\", \"content\": \"$escaped_response_data\"}"

    # transform to json array to parse with jq
    local chat_message_json="[ $chat_message ]"
    # check prompt length, 1 word =~ 1.3 tokens
    # reserving 100 tokens for next user prompt
    while (($(echo "$chat_message" | wc -c) * 1, 3 > (MAX_TOKENS - 100))); do
        # remove first/oldest QnA from prompt
        chat_message=$(echo "$chat_message_json" | jq -c '.[2:] | .[] | {role, content}')
    done
}

_gpt__log_history() {
    if [ ! -f ~/.chatgpt_history ]; then
        touch ~/.chatgpt_history
        chmod 600 ~/.chatgpt_history
    fi
    timestamp=$(date +"%Y-%m-%d %H:%M")
    echo -e "$timestamp $prompt \n$response_data \n" >>~/.chatgpt_history
}

# -d '{
#       "messages": [
#         {"role": "system", "content": "'"$escaped_system_prompt"'"},
#         '"$message"'
#         ]
#       }'
################################################################

# TODO supports stdin
# ref. https://developers.line.biz/en/docs/messaging-api/sticker-list/#sticker-definitions

function _gpt__extract-gpt-message(){
    cat - | jq -r '.choices[].message.content'
}

_gpt__cachedir=~/.cache/gpt

function _gpt__prep-sessionfile(){
    mkdir -p ${_gpt__cachedir}
    echo ${_gpt__cachedir}/gpt_session-$(TZ=Asia/Tokyo date "+%Y%m%d-%H%M%S").json
}

function _gpt__prev-output(){
    prevfile=$(ls -1t ${_gpt__cachedir} | head -n 1)
    cat ${_gpt__cachedir}/${prevfile} \
        | _gpt__extract-gpt-message
}

function g_prev-output_bat(){
    _gpt__prev-output \
        | bat -l md --file-name $prevfile
}

function g_prev-output_glow(){
    _gpt__prev-output \
        | glow -
}

function _gpt__general-gpt(){
    url=$1
    shift
    api_key=$1
    shift
    model=$1
    shift
    content="$@"
    sessionfile="$(_gpt__prep-sessionfile)"
    TMPFILE=$(mktemp gpt_tmp-XXXX.json)
cat <<EOF > ${TMPFILE}
{
  "model": "${model}",
  "messages": [
    {
      "role": "user",
      "content": "${content}"
    }
  ]
}
EOF
    curl -sX POST $url \
         -H "Authorization: Bearer $api_key" \
         -H "Content-Type: application/json" \
         -d @${TMPFILE} \
         | tee $sessionfile
    echo
    rm ${TMPFILE}
}

function _gpt__openai-gpt(){
    # NEEDS OPENAI_API_KEY
    content="$@"
    url=https://api.openai.com/v1/chat/completions
    model=gpt-3.5-turbo
    _gpt__general-gpt $url $OPENAI_API_KEY $model "$content" \
        | _gpt__extract-gpt-message
}

# https://console.groq.com/docs/quickstart
# The rate limit is set to 20 requests per minute and 25 requests per 10 minutes, operating simultaneously.
function _gpt__groq-gpt(){
    # NEEDS GROQ_API_KEY
    content="$@"
    url=https://api.groq.com/openai/v1/chat/completions
    model=llama2-70b-4096
    model=mixtral-8x7b-32768
    # https://docs.anthropic.com/claude/page/grammar-genie
    system="Your task is to take the text provided and rewrite it into a clear, grammatically correct version while preserving the original meaning as closely as possible. Correct any spelling mistakes, punctuation errors, verb tense issues, word choice problems, and other grammatical mistakes."
    # options (not used)
    temperature=0.2
    max_tokens=2048
    top_p=0.8
    options=",\"system\"=\"${system}\",\"temperature\"=${temperature},\"max_tokens\"=${max_tokens},\"top_p\"=${top_p}"
    _gpt__general-gpt $url $GROQ_API_KEY $model "$content" \
        | _gpt__extract-gpt-message
}

# https://docs.anthropic.com/claude/reference/messages_post
function _gpt__claude-gpt(){
    # NEEDS ANTHROPIC_API_KEY
    content="$@"
    model=claude-3-opus-20240229
    sessionfile="$(_gpt__prep-sessionfile)"
    TMPFILE=$(mktemp gpt_tmp-XXXX.json)
cat <<EOF > ${TMPFILE}
{
  "model": "${model}",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": "${content}"
    }
  ]
}
EOF
    curl -sX POST https://api.anthropic.com/v1/messages \
         --header "x-api-key: $ANTHROPIC_API_KEY" \
         --header "anthropic-version: 2023-06-01" \
         --header "content-type: application/json" \
         -d @${TMPFILE} \
         | tee $sessionfile
    echo
    rm ${TMPFILE}
}
