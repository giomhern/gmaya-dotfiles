# Optional interactive layer for managed work laptops.
#
# The installer never adds this file to ~/.zshrc or ~/.zprofile. Source it once,
# after company shell initialization, to add presentation and convenience
# without replacing company PATH, credentials, Git settings, or startup logic:
#
#   source ~/.config/gmaya/work-shell.zsh

[[ -o interactive ]] || return 0
[[ -z ${_GMAYA_WORK_SHELL_LOADED:-} ]] || return 0
typeset -g _GMAYA_WORK_SHELL_LOADED=1

export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export BAT_THEME="Catppuccin Mocha"

# Shared fzf behavior and palette. theme.sh updates these colors alongside the
# full shell, Neovim, Ghostty, tmux, Starship, bat, and btop.
typeset -ga _GMAYA_FZF_BINDS=(
  --bind ctrl-p:toggle-preview
  --bind ctrl-d:half-page-down
  --bind ctrl-u:half-page-up
  --bind ctrl-f:preview-half-page-down
  --bind ctrl-b:preview-half-page-up
  --bind home:preview-top
  --bind end:preview-bottom
)
typeset -g _GMAYA_FZF_COLORS='--color=fg:#cdd6f4,fg+:#cdd6f4,bg:#1e1e2e,bg+:#313244,border:#6c7086,label:#6c7086,spinner:#cba6f7,hl:#f38ba8,hl+:#f38ba8,header:#f38ba8,info:#cba6f7,pointer:#cba6f7,marker:#f5e0dc,prompt:#cba6f7'

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

export FZF_DEFAULT_COMMAND='fd --full-path --hidden --color never --type f --exclude .git --exclude node_modules --exclude dist --exclude .DS_Store'
export FZF_DEFAULT_OPTS="${_GMAYA_FZF_BINDS[*]} $_GMAYA_FZF_COLORS"

zstyle ':fzf-tab:*' fzf-flags $_GMAYA_FZF_BINDS $_GMAYA_FZF_COLORS

alias ls='ls -G'
alias la='ls -laG'
alias watch='watch '
alias gg="git log --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"

trash() { command mv -- "$@" ~/.Trash/; }
killport() { lsof -ti ":$1" | tail -n 1 | xargs kill; }
webshare() { python3 -m http.server "${1:-8000}"; }

ts() { tmux attach -t main || tmux new -s main; }
tsn() { tmux attach -t "$1" || tmux new -s "$1"; }
tp() { tmux popup -E "TMUX= tmux new-session -A -s popup"; }
tdm() { tmux display-message "$*"; }

if command -v starship >/dev/null 2>&1; then
  type starship_zle-keymap-select >/dev/null || eval "$(starship init zsh)"
fi
