# ~/.zshrc
#
#   01. Environment      general env vars, language toolchains
#   02. Path
#   03. Secrets
#   04. Plugins           zinit + completions
#   05. History
#   06. Keybindings
#   07. Shell options
#   08. Theme             catppuccin latte/macchiato, chosen by macOS appearance
#   09. Completion styling
#   10. Aliases
#   11. Functions         archives, tmux
#   12. Tooling init      starship
#
# ------------------------------------------------------------------------------
# 01. Environment
# ------------------------------------------------------------------------------

export EDITOR="nvim"
export MANPAGER="nvim +Man!"

export HOMEBREW_NO_ANALYTICS=1
export DISABLE_AUTO_UPDATE=true

# Java — pinned to 25 (team standard). The unversioned `openjdk` formula is 26,
# so target openjdk@25 explicitly rather than letting brew decide.
export JAVA_HOME=/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home

# Go
export GOROOT=/opt/homebrew/opt/go/libexec
export GOPATH=$HOME/go
export GO111MODULE=on

# Node — prefer IPv4 to avoid slow/failing AAAA lookups
export NODE_OPTIONS="--dns-result-order=ipv4first"

# AWS
export AWS_PROFILE=cnd-gmaya-sandbox-Standard_Administrator

export ANTHROPIC_MODEL="claude-opus-5"

# ------------------------------------------------------------------------------
# 02. Path
# ------------------------------------------------------------------------------

path=(
  $JAVA_HOME/bin
  $HOME/.docker/bin
  $HOME/.local/bin
  $GOROOT/bin
  $GOPATH/bin
  $path
)

# Homebrew ruby ahead of the system one, plus its user gem bin dir
if [[ -d /opt/homebrew/opt/ruby/bin ]]; then
  path=(/opt/homebrew/opt/ruby/bin "$(gem environment gemdir)/bin" $path)
fi

typeset -U path PATH   # drop duplicate entries

# ------------------------------------------------------------------------------
# 03. Secrets
# ------------------------------------------------------------------------------

[[ -f $HOME/.zshsecrets ]] && source $HOME/.zshsecrets

# Guarded so a missing file doesn't error on every shell start.
[[ -r $HOME/.secrets/github.com ]] && export GITHUB_TOKEN=$(<$HOME/.secrets/github.com)

# ------------------------------------------------------------------------------
# 04. Plugins
# ------------------------------------------------------------------------------

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

autoload -Uz compinit && compinit
zinit cdreplay -q

# ------------------------------------------------------------------------------
# 05. History
# ------------------------------------------------------------------------------

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

setopt append_history          # add to the history file rather than replacing it
setopt share_history           # sync history across running shells
setopt hist_ignore_space       # a leading space keeps a command out of history
setopt hist_ignore_all_dups    # drop older duplicates of a repeated command
setopt hist_save_no_dups       # never write duplicates to the history file
setopt hist_find_no_dups       # skip duplicates when searching

# ------------------------------------------------------------------------------
# 06. Keybindings
# ------------------------------------------------------------------------------

bindkey -v                                              # vi mode

bindkey "^[[A"    history-beginning-search-backward     # up
bindkey "^[[B"    history-beginning-search-forward      # down
bindkey "^[[1;3C" vi-forward-word                       # alt+right
bindkey "^[[1;3D" vi-backward-word                      # alt+left
bindkey "^[[1;3A" beginning-of-line                     # alt+up
bindkey "^[[1;3B" end-of-line                           # alt+down

# ctrl+x ctrl+e — edit the current command line in $EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# ------------------------------------------------------------------------------
# 07. Shell options
# ------------------------------------------------------------------------------

setopt globdots                # let globs match dotfiles
setopt interactive_comments    # allow # comments at the prompt

# ------------------------------------------------------------------------------
# 08. Theme
# ------------------------------------------------------------------------------

# The Catppuccin flavour follows the macOS appearance: latte when the system is
# light, macchiato when it is dark. AppleInterfaceStyle only exists while dark
# mode is on — in light mode the key is absent and `defaults read` fails, which
# is the documented way to detect this.
#
# Ghostty and Neovim handle themselves and switch live (ghostty/config sets both
# flavours at once; Neovim asks the terminal for its background color). The
# tools below are configured through environment variables, so they are decided
# once per shell: after flipping appearance, open a new shell to catch them up.
if defaults read -g AppleInterfaceStyle &>/dev/null; then
  export CATPPUCCIN_FLAVOR="macchiato"
else
  export CATPPUCCIN_FLAVOR="latte"
fi

export GLAMOUR_STYLE=$HOME/.config/glamour-catppuccin-$CATPPUCCIN_FLAVOR.json

if [[ $CATPPUCCIN_FLAVOR == latte ]]; then
  export BAT_THEME="Catppuccin Latte"
  export STARSHIP_CONFIG=$HOME/.config/starship-latte.toml
  _FZF_COLORS='--color=fg:#4c4f69,fg+:#4c4f69,bg:#eff1f5,bg+:#ccd0da,border:#9ca0b0,label:#9ca0b0,spinner:#8839ef,hl:#d20f39,hl+:#d20f39,header:#d20f39,info:#8839ef,pointer:#8839ef,marker:#dc8a78,prompt:#8839ef'
else
  export BAT_THEME="Catppuccin Macchiato"
  export STARSHIP_CONFIG=$HOME/.config/starship.toml
  _FZF_COLORS='--color=fg:#cad3f5,fg+:#cad3f5,bg:#24273a,bg+:#363a4f,border:#6e738d,label:#6e738d,spinner:#c6a0f6,hl:#ed8796,hl+:#ed8796,header:#ed8796,info:#c6a0f6,pointer:#c6a0f6,marker:#f4dbd6,prompt:#c6a0f6'
fi

# btop can only name one theme file in its config, so btop.conf points at
# themes/current.theme and we repoint that symlink instead. Guarded so a shell
# start does no disk write in the common case where it already matches.
_btop_theme=$HOME/.config/btop/themes/current.theme
if [[ "$(readlink $_btop_theme 2>/dev/null)" != "catppuccin_$CATPPUCCIN_FLAVOR.theme" ]]; then
  ln -sfn "catppuccin_$CATPPUCCIN_FLAVOR.theme" "$_btop_theme" 2>/dev/null
fi
unset _btop_theme

# Shared by FZF_DEFAULT_OPTS and fzf-tab so both stay in sync.
_FZF_BINDS=(
  --bind ctrl-p:toggle-preview
  --bind ctrl-d:half-page-down
  --bind ctrl-u:half-page-up
  --bind ctrl-f:preview-half-page-down
  --bind ctrl-b:preview-half-page-up
  --bind home:preview-top
  --bind end:preview-bottom
)

# _FZF_COLORS is set further up, with the rest of the flavour-dependent values.

eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND='fd --full-path --hidden --color never --type f --exclude .git --exclude node_modules --exclude dist --exclude .DS_Store'
export FZF_DEFAULT_OPTS="${_FZF_BINDS[*]} $_FZF_COLORS"

# ------------------------------------------------------------------------------
# 09. Completion styling
# ------------------------------------------------------------------------------

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no                           # fzf-tab handles the menu
zstyle ':fzf-tab:*' fzf-flags $_FZF_BINDS $_FZF_COLORS

# ------------------------------------------------------------------------------
# 10. Aliases
# ------------------------------------------------------------------------------

alias ls='ls --color'
alias la='ls -la --color'
alias watch='watch '                     # trailing space: expand aliases after watch
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222'
alias gg="git log --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"

# ------------------------------------------------------------------------------
# 11. Functions
# ------------------------------------------------------------------------------

# --- files & archives ---------------------------------------------------------

trash()     { mv $@ ~/.Trash; }
targz()     { tar -zcvf $1.tar.gz ${@:2}; rm -r ${@:2}; }
untargz()   { tar -zxvf $1; rm -r $1; }
listtargz() { tar -ztvf $1; }

# Kill whatever is listening on the given port
killport() { lsof -i :$1 | awk '{print $2}' | tail -n 1 | xargs kill; }

# Serve the current directory over HTTP
webshare() {
  if [[ $(python --version 2>&1) == *2\.* ]]; then
    python -m SimpleHTTPServer $@
  else
    python -m http.server $@
  fi
}

# --- tmux ---------------------------------------------------------------------

ts()  { tmux attach -t main || tmux new -s main; }              # main session
tsn() { tmux attach -t $1 || tmux new -s $1; }                  # named session
# Scratch popup. Same as the Alt-t binding in .tmux.conf; TMUX= is required or
# tmux refuses to attach from inside an existing client.
tp()  { tmux popup -E "TMUX= tmux new-session -A -s popup"; }
tdm() { tmux display-message $1; }

# ------------------------------------------------------------------------------
# 12. Tooling init  (keep last — these hook the prompt and precmd)
# ------------------------------------------------------------------------------

type starship_zle-keymap-select >/dev/null || eval "$(starship init zsh)"
