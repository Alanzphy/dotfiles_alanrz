# Omarchy defaults for Zsh
export EDITOR="${EDITOR:-omarchy-launch-editor --inline}"
export SUDO_EDITOR="${SUDO_EDITOR:-$EDITOR}"
export BROWSER="${BROWSER:-omarchy-launch-browser}"
export BAT_THEME="${BAT_THEME:-ansi}"
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

_zsh_add_path() {
  [[ -d "$1" ]] || return
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
  esac
}

_zsh_add_path "$HOME/.local/bin"

export PATH
unfunction _zsh_add_path
