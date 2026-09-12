if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# User-installed tools such as Codex.
[[ -d $HOME/.local/bin ]] && path=($HOME/.local/bin $path)

[[ -f $HOME/.zprofile.local ]] && source $HOME/.zprofile.local
