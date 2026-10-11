#!/usr/bin/env bash
# Reinstalls third-party Omarchy shell plugins listed in plugin-manifest.json
# Usage: ./restore-plugins.sh [path-to-manifest]
set -euo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${1:-$SELF_DIR/plugin-manifest.json}"

# Packages implemented noted in plugin-manifest.json (Package key) are restored with
# omarchy pkgs, e.g. flea-bin ships flea-shelf (the file manager shelf plugin).

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
