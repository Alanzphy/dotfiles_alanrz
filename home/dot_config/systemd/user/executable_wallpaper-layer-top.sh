#!/usr/bin/env bash
# Keep waywallen's wallpaper layer above the Omarchy shell's background layer.
#
# Hyprland stacks layer surfaces of the same level in creation order: whenever
# the Omarchy shell (Quickshell) recreates its `omarchy-background` surface —
# at session start or on `omarchy restart shell` — that surface is created last
# and covers waywallen's video wallpaper, leaving the static wallpaper visible.
#
# Fix: Hyprland emits `openlayer>>omarchy-background` on the compositor's
# socket2. On that event, SIGTERM `waywallen-layer-shell`; the waywallen daemon
# respawns it, and the respawned surface is created last → back on top.
set -u

WANT='openlayer>>omarchy-background'
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/waywallen"
state_file="$state_dir/raise-layer.last"
mkdir -p "$state_dir"

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

raise() {
  now=$(date +%s)
  last=$(head -n1 "$state_file" 2>/dev/null || echo 0)
  (( now - last < 3 )) && return 0   # debounce: two monitors fire once each
  printf '%s\n' "$now" > "$state_file"
  pkill -TERM -f '^/usr/bin/waywallen-layer-shell '
}

while :; do
  sock=$(ls -dt "$runtime_dir"/hypr/* 2>/dev/null | head -n1)/.socket2.sock
  if [[ -S "$sock" ]]; then
    while IFS= read -r event; do
      [[ "$event" == "$WANT"* ]] || continue
      raise
    done < <(socat -u "UNIX-CONNECT:$sock" -)
  fi
  sleep 5  # socket vanished (compositor restart); reconnect
done
