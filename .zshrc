##############################
# 1. CORE SHELL SETUP
##############################

# Case-insensitive globbing and completion
setopt NO_CASE_GLOB
setopt AUTO_CD
setopt CDABLE_VARS

# # Completion system (fast + cached)
autoload -Uz compinit
compinit -d ~/.zcompdump

# Prevent virtualenv prompt noise
export VIRTUAL_ENV_DISABLE_PROMPT=1

  ##############################
  # GIT AUTOCOMPLETION (UPGRADED)
  ##############################


  # Git completion improvements
  zstyle ':completion:*:*:git:*' tag-order 'branches' 'remotes' 'tags'
  zstyle ':completion:*:*:git:*' group-name ''
  zstyle ':completion:*:*:git:*' menu select

  ##############################
  # BETTER BRANCH NAVIGATION
  ##############################

  # show recent branches easily
  gb() {
    git branch --sort=-committerdate | head -n 10
  }

##############################
# 2. PATH (must come early)
##############################

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

# npm global tools
export PATH="$HOME/.npm-global/bin:$PATH"

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# late
export PATH="$HOME/.local/bin:$PATH"


##############################
# 3. DEV ENVIRONMENT
##############################

# Java
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Conda (lazy only)
__conda_loaded=0


##############################
# 4. ALIASES
##############################

# Tools
alias ls='eza'
alias tree='tree -C -L 2'
alias f='fd'
alias ff='fastfetch'
alias cat='bat'

# Neovim profiles
alias lazy="NVIM_APPNAME=nvim-lazy nvim"
alias chad="NVIM_APPNAME=nvim-nvchad nvim"

# late.sh
alias latessh="ssh -i ~/.ssh/late_throwaway late.sh"

alias server="python3 -m http.server"


##############################
# 5. ZSH PLUGINS / UI
##############################

# Syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[command]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[function]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#89b4fa'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#585b70'
ZSH_HIGHLIGHT_STYLES[error]='fg=#f38ba8,bold'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[variable]='fg=#94e2d5'

# Starship prompt (always last UI layer)
eval "$(starship init zsh)"

eval "$(~/.local/bin/mise activate zsh)"
eval "$(fnm env)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

