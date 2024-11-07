export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/vars.zsh"
source "$HOME/.config/zsh/env.zsh"
source "$HOME/.config/zsh/work.zsh"

eval $(/opt/homebrew/bin/brew shellenv)

export PATH="/Users/dancastillo/.local/bin:$PATH"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# eval "$(jp hook bash)"

export VOLTA_HOME="$HOME/.volta"
export VOLTA_BIN_PATH="$HOME/.volta/bin"

# export PNPM_HOME="$HOME/.volta/bin"
export VOLTA_FEATURE_PNPM=1

export PATH="$PNPM_HOME:$VOLTA_HOME/bin:$VOLTA_BIN_PATH:$PATH"

# pnpm
export PNPM_HOME="/Users/dancastillo/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# bun completions
[ -s "/Users/dancastillo/.bun/_bun" ] && source "/Users/dancastillo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "/Users/dancastillo/.deno/env"
