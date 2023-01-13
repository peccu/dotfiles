# -*- coding:utf-8; mode:shell-script  -*-
if exists minikube ; then
    # curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    alias mk='minikube'
    alias kubectl='minikube kubectl --'
    alias kc='kubectl'
    # this needs bash_completion
    source <(kubectl completion bash)
    complete -o default -F __start_kubectl kc
    # minikube start --listen-address=0.0.0.0
fi
