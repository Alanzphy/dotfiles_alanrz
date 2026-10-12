# f5vpn — ajustes que hicimos para que corriera bien

## El fix real (verificado 2026-10-11)

El problema eran **crashes de WebKitGTK (OpenGL/DMA-BUF) al abrir la ventana de
login del VPN**. La solución quedó como un launcher propio en el usuario:

```
~/.local/share/applications/f5vpn-ng.desktop     (editado 2026-09-29 20:41, 35 min después de instalar)
Exec=env GDK_BACKEND=x11 WEBKIT_DISABLE_DMABUF_RENDERER=1 /usr/bin/f5vpn-launcher %u
```

- `pkg` del sistema (`f5vpn-ng 7272.0.0.2-2`, `packages/aur-foreign.txt` line 9) monta el binario/todos —
  `pacman -Qkk` no ve alteraciones porque el fix vive en un archivo **de usuario**, no del paquete.
- La unidad `com.f5.f5vpn.service` (systemd --user) quedó **stock** (misma hora de install).

## Restore después del cutover

```bash
paru -S --needed - < packages/aur-foreign.txt            # instala f5vpn-ng con fixes de build
mkdir -p ~/.local/share/applications
cp packages/f5vpn-snapshot/f5vpn-ng.desktop.user ~/.local/share/applications/f5vpn-ng.desktop
update-desktop-database ~/.local/share/applications
```

(o deja que chezmoi la aplique si algún día se pasa a `dot_local/share/applications/`)

## Snapshots (por si el AUR cambia paths)

- `f5vpn-snapshot/f5vpn-ng.desktop.user` — el launcher con el fix (lo queосв importa)
- `f5vpn-snapshot/f5vpn-ng.desktop.stock` — el de fábrica, para diff
- `f5vpn-snapshot/com.f5.f5vpn.service.stock` — unit user de fábrica

## Desechable

- `~/.F5Networks/*.log` (19 MB de logs), `~/.cache/f5vpn-ng` — nada config.
- Paso manual post-install: login del VPN una vez (no scriptea ble).
