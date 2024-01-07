alias cd..="cd ../"
alias ..="cd ../"
alias ...="cd ../../"
alias c="clear"
alias g="git"
alias ws="webstorm ."
alias run="npm run "
alias d="docker"
alias dc="docker container"
alias vim="nvim"
alias dev="cd ~/dev/"
alias zshrc="vim ~/.zshrc"
alias nvconfig="vim ~/.config/nvim/init.vim"
alias lunarvim_config="vim ~/.config/lvim/config.lua"

alias brewctl="/usr/local/bin/kubectl"
alias topnodes="kubectl top node | sort -r -k 3"
alias toppods="kubectl top pod | sort -r -k 3"
alias ll="ls -al"
alias k="kubectl"
alias cronjobs="kubectl get cronjobs --all-namespaces"
alias pods="kubectl get pods --all-namespaces"
alias kjobs="kubectl get jobs --all-namespaces"
alias services="kubectl get services --all-namespaces"
alias nodes="kubectl get nodes -o wide"
alias endpoints="kubectl get endpoints --all-namespaces"
alias events="kubectl get events --all-namespaces"
alias pvc="kubectl get pvc --all-namespaces"
alias pv="kubectl get pv --all-namespaces"
alias containers="kubectl get pods --all-namespaces -o jsonpath="{..image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c"
alias deployments="kubectl get deployments --all-namespaces"
alias podauto="kubectl get horizontalpodautoscaler"
alias hpa="kubectl get hpa --all-namespaces"
alias logs="kubectl logs $1"
alias describe="kubectl describe $1 $2"

alias vimkeys = "cat ~/.config/nvim/keymaps.txt"

