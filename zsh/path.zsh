# brew
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'


export VOLTA_HOME="$HOME/.volta"

# export PNPM_HOME="$HOME/.volta/bin"
export VOLTA_FEATURE_PNPM=1

export PATH="$PNPM_HOME:$VOLTA_HOME/bin:$PATH"


# pnpm
export PNPM_HOME="/Users/dancastillo/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun end
