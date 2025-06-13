
if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"
source ~/.config/fzf/fzf-git.sh

# VSCode Socket Path
function make_code_work() {
    # make code work in tmux
    if [ -z "$1" ]; then
        echo "Provide a tmux session name"
        return 1
    fi
    SESSION_NAME=$1
    t=$(set | grep VSCODE_IPC_HOOK_CLI= | head -n 1 | cut -d'=' -f2)
    if [ -z "$t" ]; then
        echo "VSCODE_IPC_HOOK_CLI is not set. Are you running this in a VS Code terminal?"
        return 1
    fi
    echo "Socket to your current vscode: $t"
    cmd="export VSCODE_IPC_HOOK_CLI=$t"
    echo cmd=$cmd
    tmux list-windows -t $SESSION_NAME -F '#{window_id}' | while read WINDOW_ID; do
        tmux list-panes -t $WINDOW_ID -F '#{pane_id}' | while read PANE_ID; do
            echo "Executing command in window $WINDOW_ID, pane $PANE_ID"
            tmux send-keys -t $PANE_ID "$cmd" C-m
        done
    done
}

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice as"program" pick"bin/git-fuzzy"
zinit light bigH/git-fuzzy

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:git-checkout:*' sort false

# Aliases
alias ls='ls --color'
alias c='clear'
alias gz='git fuzzy'
alias cd='z'
alias mcw='make_code_work'

# env
export PATH=$PATH:/usr/local/go/bin:/root/.local/bin
export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
. "$HOME/.cargo/env"

# Init 
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
WORDCHARS='-'


fastfetch

. "$HOME/.local/bin/env"
