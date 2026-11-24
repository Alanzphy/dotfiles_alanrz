#!/usr/bin/env bash
# Aplica la configuración de sistema (/etc, UFW, PAM SDDM, perfil de energía) de ruxzbox.
# Uso: sudo ./system/apply.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta este script como root: sudo $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. sysctl hardening, udev BFQ para HDDs y tope de journald (1G)
install -Dm644 "$SCRIPT_DIR/etc/sysctl.d/99-hardening.conf" /etc/sysctl.d/99-hardening.conf
install -Dm644 "$SCRIPT_DIR/etc/udev/rules.d/61-hdd-bfq.rules" /etc/udev/rules.d/61-hdd-bfq.rules
install -Dm644 "$SCRIPT_DIR/etc/systemd/journald.conf.d/10-size-limit.conf" /etc/systemd/journald.conf.d/10-size-limit.conf

sysctl -p /etc/sysctl.d/99-hardening.conf
udevadm control --reload-rules
udevadm trigger --subsystem-match=block
systemctl restart systemd-journald

# 2. Auto-desbloqueo de GNOME Keyring (login.keyring) desde SDDM
if [[ -f /etc/pam.d/sddm ]]; then
  if ! grep -q "^-auth.*pam_gnome_keyring.so" /etc/pam.d/sddm; then
    sed -i "/^-auth.*pam_kwallet5.so/i -auth       optional    pam_gnome_keyring.so" /etc/pam.d/sddm
  fi
  if ! grep -q "^-password.*pam_gnome_keyring.so" /etc/pam.d/sddm; then
    sed -i "/^password.*include.*system-login/a -password   optional    pam_gnome_keyring.so    use_authtok" /etc/pam.d/sddm
  fi
fi

# 3. UFW: quitar reglas abiertas a 0.0.0.0/0 / ::/0 para LocalSend y KDE Connect
#    y limitarlas a redes privadas LAN + Tailscale; silenciar log spam.
if command -v ufw >/dev/null 2>&1; then
  ufw logging off
  ufw delete allow 53317/tcp 2>/dev/null || true
  ufw delete allow 53317/udp 2>/dev/null || true
  ufw delete allow 1714:1764/tcp 2>/dev/null || true
  ufw delete allow 1714:1764/udp 2>/dev/null || true

  for net in 192.168.0.0/16 10.0.0.0/8 172.16.0.0/12 100.64.0.0/10 fe80::/10 fc00::/7; do
    ufw allow from "$net" to any port 53317 comment "LocalSend private"
    ufw allow from "$net" to any port 1714:1764 proto tcp comment "KDE Connect private"
    ufw allow from "$net" to any port 1714:1764 proto udp comment "KDE Connect private"
  done
fi

# 4. Perfil de energía balanced (mantiene boost máximo en carga, baja calor/consumo en reposo)
if command -v powerprofilesctl >/dev/null 2>&1; then
  powerprofilesctl set balanced || true
fi

echo "Configuración de sistema aplicada correctamente."
