# -*- coding:utf-8; mode:shell-script  -*-
# GCLOUD_MY_HOME is in ~/.bash/conf/0_env_local.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$GCLOUD_MY_HOME/path.zsh.inc" ]; then . "$GCLOUD_MY_HOME/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$GCLOUD_MY_HOME/completion.zsh.inc" ]; then . "$GCLOUD_MY_HOME/completion.zsh.inc"; fi
