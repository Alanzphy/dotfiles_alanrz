#!/usr/bin/env bash
# restore-tailscale.sh — traer el tailnet de vuelta tras cutover (ruxz / Alanzphy@)
#
# Motor de 3 modos (requiere sudo):
#   ./scripts/restore-tailscale.sh save     → guarda identidad+keys (identidad dot /var/lib/tailscale)
#   ./scripts/restore-tailscale.sh restore  → la vuelve a poner (ruxz regresa conectado IGUAL, sin login)
#   ./scripts/restore-tailscale.sh fresh    → login nuevo por browser (si perdiste el estado)
#
# Flags actuales del tailnet (verificados 2026-10-11): sin exit-node, MagicDNS (CorpDNS) on,
# ShieldsUp off, sin rutas anunciadas → `tailscale up --hostname <host>` default flags.
set -euo pipefail

STAGE="${STAGE_DIR:-/mnt/Extra/staging/tailscale}"

save() {
  systemctl stop tailscaled
  mkdir -p "$STAGE"
  tar -czf "$STAGE/tailscaled.state.tgz" -C /var/lib tailscale
  systemctl start tailscaled
  echo "identidad guardada en: $STAGE/tailscaled.state.tgz"
  echo "(copiala también al Seagate como segundo seguro)"
}

restore() {
  systemctl stop tailscaled
  tar -xzf "$STAGE/tailscaled.state.tgz" -C /var/lib
  systemctl enable --now tailscaled
  sleep 2
  tailscale status | head -6
  echo "== ruxz conectado con la misma identidad (sin login) =="
  tailscale ip -4
}

fresh() {
  systemctl enable --now tailscaled
  echo "Entra con Alanzphy@ en el siguiente link (any browser):"
  sudo tailscale up --hostname "$(hostname)" 2>&1 | grep -Eo 'https://login\.tailscale\.com/[a-zA-Z0-9./]+' || true
  echo
  echo "Nota: si aparece 'ruxz' duplicado en login.tailscale.com, borra el dispositivo viejo."
  tailscale status | head -6
}

case "${1:-}" in
  save)    save ;;
  restore) restore ;;
  fresh)   fresh ;;
  *) echo "usage: sudo $0 {save|restore|fresh}"; exit 1 ;;
esac
