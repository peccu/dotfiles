# Activate p10k
# maneged in .chezmoiexternal.toml
source ~/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# add TMUX_PANE
function prompt_my_tmux_pane() {
    local title=$(tmux display-message -p '#{pane_title}' 2>/dev/null | cut -c1-15)
    p10k segment -b teal -t "$TMUX_PANE $title"
}
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=my_tmux_pane
