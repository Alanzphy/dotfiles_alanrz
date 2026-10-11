#!/bin/bash

set -eu

direction="${1:-next}"
monitor_data=$(hyprctl monitors -j)
monitor=$(printf '%s' "$monitor_data" | jq -r '.[] | select(.focused == true) | .name')
current=$(printf '%s' "$monitor_data" | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
workspace_data=$(hyprctl workspaces -j)
case "$monitor" in
  HDMI-A-1)
    min=1
    max=5
    ;;
  DP-3)
    min=6
    max=10
    ;;
  *)
    exit 1
    ;;
esac

if (( current < min || current > max )); then
  current=$min
fi

case "$direction" in
  next)
    step=1
    ;;
  prev)
    step=-1
    ;;
  *)
    exit 2
    ;;
esac

target=$current
for ((i = 0; i < max - min + 1; i++)); do
  target=$((target + step))
  (( target > max )) && target=$min
  (( target < min )) && target=$max

  if printf '%s' "$workspace_data" | jq -e --argjson id "$target" \
    'any(.[]; .id == $id and .windows > 0)' >/dev/null; then
    break
  fi
done

hyprctl dispatch "hl.dsp.focus({ workspace = \"$target\" })"
