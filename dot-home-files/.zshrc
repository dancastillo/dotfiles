export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/vars.zsh"
source "$WORK/.config/zsh/work.zsh"

eval $(/opt/homebrew/bin/brew shellenv)

export PATH="/Users/dancastillo/.local/bin:$PATH"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
