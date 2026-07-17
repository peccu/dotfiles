# -*- coding:utf-8; mode:shell-script  -*-
# GCLOUD_MY_HOME is in ~/.bash/conf/0_env_local.sh

# PATH for the Google Cloud SDK is now set shell-agnostically in
# ~/.bash/conf/0_path.sh (so bash gets it too), loaded via ~/.zshenv.

# The next line enables shell command completion for gcloud.
if [ -f "$GCLOUD_MY_HOME/completion.zsh.inc" ]; then . "$GCLOUD_MY_HOME/completion.zsh.inc"; fi
