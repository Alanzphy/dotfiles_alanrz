# f5vpn — those "adjustments that had to be made to run it"

Findings (2026-10-11 audit, `pacman -Qkk f5vpn-ng` → `0 altered files`):

- All the compat fixes (legacy TLS etc.) **live in the AUR build** of
  `f5vpn-ng 7272.0.0.2-2`, not in user files. Nothing else is needed.
- Restore = pkg list already covers it: `packages/aur-foreign.txt` (line 9).
  `paru -S --needed - < packages/aur-foreign.txt` brings it baked.
- The only f5 artifacts on disk are diagnostics:
  `~/.F5Networks/*.log` (19 MB) and `~/.cache/f5vpn-ng` — **both disposable**,
  not staged on purpose.
- Post-install manual step: VPN login/session once, nothing scriptable.
