#!/bin/bash
# -*- shell-script -*-
# initialize dot files

# please edit as you need

echo -n "initializing at $(pwd)"
sleep 1
echo -n .
sleep 1
echo -n .
sleep 1
echo .

function bkup(){
    if [ -e $1 ]
    then
        mv $1 $1.$(date +%Y%m%d-%H%M%S)
    fi
}

function rmdot(){
    dest=${1/dot}
    bkup $dest
    mv $1 $dest
}

# clone from github
GH_URL=https://github.com/peccu/
for i in dot.zsh dot.pj dot.emacs.d bin
do
    bkup $i
    git clone $GH_URL$i.git
done

# clone from bitbucket
BB_URL=https://peccu@bitbucket.org/peccu/
for i in dot.histories dot.env
do
    bkup $i
    git clone $BB_URL$i.git
done

for i in dot.zsh dot.emacs.d dot.histories dot.env
do
    rmdot $i
done
