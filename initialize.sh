#!/bin/bash
# -*- coding:utf-8; mode:shell-script  -*-
# initialize dot files

detectpath(){
    local binpath=.
    # for Codesandbox
    if [ "$HOME" == "/project/home/peccu" ]
    then
      binpath=~/.nix-profile/bin
    fi
    # for Codespace
    if [ "$USER" == "codespace" ]
    then
      binpath=~/.local/bin
    fi
    echo $binpath
}
echo "bin path is: $(detectpath)"
if ! which chezmoi >/dev/null 2>&1
then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $(detectpath)
  hash -r
fi
chezmoi init peccu
echo check chezmoi diff and apply

### Use chezmoi
## install
# sh -c "$(curl -fsLS get.chezmoi.io)" -- -b path/to/bin
## init into ~/.local/share/chezmoi
# chezmoi init https://github.com/peccu/dotfiles.git
## or with dotfiles repo and apply and remove sources (--one-shot)
# chezmoi init --apply --one-shot peccu
## show diff
# chezmoi diff
## apply (n: dry-run, v: verbose)
# chezmoi apply -nv
## add local into chezmoi
# chezmoi add ~/.dotfile
## edits in ~/.local/share/chezmoi. (Needs chezmoi apply after save)
# chezmoi edit ~/.dotfile
## push modification to github
# chezmoi cd
# git add .
# git push -u origin HEAD
## pull and apply
# chezmoi update -nv

# https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/#use-completely-different-dotfiles-on-different-machines
### templating
## shows variables
# chezmoi data
## template execution
# chezmoi execute-template "{{ .chezmoi.os }}/{{ .chezmoi.arch }}"
## in template (- removes spaces)
# {{- if eq .chezmoi.hostname "work-laptop" }}
# some conf
# {{- end }}

### ignore files
## check
# chezmoi ignored
## in ~/.local/share/chezmoi/.chezmoiignore
# README.md
# {{- if ne .chezmoi.hostname "work-laptop" }}
# .work
# {{- end }}
