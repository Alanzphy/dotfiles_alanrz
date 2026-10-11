#!/usr/bin/env bash
# Reinstalls third-party Omarchy shell plugins listed in plugin-manifest.json
# Usage: ./restore-plugins.sh [path-to-manifest]
set -euo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${1:-$SELF_DIR/plugin-manifest.json}"

# Vendored (non-git) plugins: just copy them back into place
if [ -d "$SELF_DIR/plugins/io.github.thisisgm.flea-shelf" ]; then
  mkdir -p ~/.config/omarchy/plugins
  cp -r "$SELF_DIR/plugins/io.github.thisisgm.flea-shelf" ~/.config/omarchy/plugins/
fi

while IFS=$'\t' read -r pid url; do
  [ -n "$url" ] || continue
  if [ -d ~/.config/omarchy/plugins/$pid ]; then
    echo "SKIP $pid (already installed)"
    continue
  fi
  omarchy plugin add "$url" --yes
  omarchy plugin enable "$pid"
  echo "RESTORED $pid from $url"
done < <(jq -r '.plugins[] | select(.git != null) | .id, .git' "$MANIFEST" | paste - -)
