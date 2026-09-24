# ~/.zshrc
#
#   01. Environment      general env vars, language toolchains
#   02. Path
#   03. Secrets
#   04. Plugins           zinit + completions
#   05. History
#   06. Keybindings
#   07. Shell options
#   08. Theme             shared palette (fzf, bat)
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

# Use Homebrew toolchains when present, on either Apple Silicon or Intel Macs.
if command -v brew >/dev/null 2>&1; then
  _brew_prefix=$(brew --prefix)
  _java_prefix=$(brew --prefix openjdk 2>/dev/null) || _java_prefix=""
  [[ -n $_java_prefix ]] && export JAVA_HOME="$_java_prefix/libexec/openjdk.jdk/Contents/Home"
else
  _brew_prefix=""
fi

# Go
if [[ -n $_brew_prefix && -d $_brew_prefix/opt/go/libexec ]]; then
  export GOROOT="$_brew_prefix/opt/go/libexec"
fi
export GOPATH=$HOME/go
export GO111MODULE=on

# ------------------------------------------------------------------------------
# 02. Path
# ------------------------------------------------------------------------------

path=(
  ${JAVA_HOME:+$JAVA_HOME/bin}
  $HOME/.docker/bin
  $HOME/.local/bin
  ${GOROOT:+$GOROOT/bin}
  $GOPATH/bin
  $path
)

# Homebrew ruby ahead of the system one, plus its user gem bin dir
if [[ -n $_brew_prefix && -d $_brew_prefix/opt/ruby/bin ]]; then
  path=("$_brew_prefix/opt/ruby/bin" "$(gem environment gemdir)/bin" $path)
fi

typeset -U path PATH   # drop duplicate entries

# ------------------------------------------------------------------------------
# 03. Secrets
# ------------------------------------------------------------------------------

[[ -f $HOME/.zshsecrets ]] && source $HOME/.zshsecrets

# Machine-specific, non-secret settings belong here.
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

unset _brew_prefix _java_prefix

# ------------------------------------------------------------------------------
# 04. Plugins
# ------------------------------------------------------------------------------

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -r $ZINIT_HOME/zinit.zsh ]] && command -v git >/dev/null 2>&1; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" || \
    print -u2 "Zinit bootstrap failed; continuing without shell plugins."
fi

if [[ -r $ZINIT_HOME/zinit.zsh ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab

  autoload -Uz compinit && compinit
  zinit cdreplay -q
fi

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

export BAT_THEME="Catppuccin Mocha"

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
_FZF_COLORS='--color=fg:#cdd6f4,fg+:#cdd6f4,bg:#1e1e2e,bg+:#313244,border:#6c7086,label:#6c7086,spinner:#cba6f7,hl:#f38ba8,hl+:#f38ba8,header:#f38ba8,info:#cba6f7,pointer:#cba6f7,marker:#f5e0dc,prompt:#cba6f7'

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

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

alias ls='ls -G'
alias la='ls -laG'
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

if command -v starship >/dev/null 2>&1; then
  type starship_zle-keymap-select >/dev/null || eval "$(starship init zsh)"
fi
