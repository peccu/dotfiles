# -*- coding:utf-8; mode:shell-script  -*-
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html#cli-command-completion-enable
exists aws && complete -C $(which aws_completer) aws
