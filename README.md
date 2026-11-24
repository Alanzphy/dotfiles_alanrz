# dotfiles_alanrz

Dotfiles for Linux (Omarchy) and macOS, managed with [chezmoi](https://www.chezmoi.io).

The source lives in `home/` (see `.chezmoiroot`). OS-specific files are filtered
by `home/.chezmoiignore`: Linux-only paths are skipped on macOS and vice versa.

Design rules (why each thing is here):

1. **Only decisions reach the repo.** App state, caches, auto-generated files,
   and Omarchy defaults restored by `omarchy update` or first-run provisioning
   (`~/.local/state/omarchy`, `omarchy/backgrounds/`, `btop.conf`, post-update
   invite hooks…) are deliberately excluded. Repo files are things that
   *regrow* differently without them (key bindings, monitor layout, bar layout,
   plugin manifest, FHS browser flags).
2. **Secrets are never committed.** Credential files arrive as `create_`
   templates: chezmoi creates them ONCE with clearly-marked slots
   (`TODO-REEMPLAZAR-KEY`) and then never touches them again — so syncing,
   re-applying, and rotating that expired API key is a manual `vim` + restart,
   and `git grep sk-` across all history stays zero.
3. **What can't be a template is encrypted.** This repo is public, so `~/.ssh`
   (config, known_hosts, private key) goes in as age-encrypted
   `encrypted_*.age` files. The age identity itself is committed only as
   `key.txt.age`, encrypted with a passphrase; `chezmoi init` asks for that
   passphrase once per machine and writes `~/.config/chezmoi/key.txt`.

## New machine (Linux / Omarchy)

```bash
# 0. install Omarchy per its docs, then:
omarchy pkg add chezmoi
git clone https://github.com/Alanzphy/dotfiles_alanrz ~/Projects/dotfiles_alanrz
chezmoi init --source ~/Projects/dotfiles_alanrz --apply   # asks the age passphrase once (decrypts ~/.ssh)

# 0a. packages (one list, names only, no versions; yay resolves repos first, AUR otherwise):
P=~/Projects/dotfiles_alanrz/packages
yay -S --needed - < "$P/packages.txt"
xargs -r flatpak install -y flathub < "$P/flatpak.txt"
# services beyond Omarchy's defaults: see packages/services-enabled.txt

# 0b. zsh: Oh My Zsh + plugins are NOT in the repo (they self-update via git)
RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
P=~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions $P/zsh-autosuggestions
git clone https://github.com/Aloxaf/fzf-tab $P/fzf-tab
git clone https://github.com/z-shell/F-Sy-H $P/F-Sy-H
chsh -s /usr/bin/zsh                     # needs zsh, zsh-completions pkgs

# 1. restore Omarchy shell plugins (15; reads ~/.config/omarchy/plugin-manifest.json)
~/.config/omarchy/restore-plugins.sh

# 2. flea (file manager + shelf plugin): comes from a package, not a plugin clone
omarchy pkg aur add flea-bin && flea --default

# 3. keys: ~/.config/hypr/envs.lua is a create-once slot for private hl.env() vars

# 4. theme (re-generates backgrounds/, themed/, shell updates)
omarchy theme set "<your-theme>"

# 5. exegol (if you use it): pipx install exegol
#    exegol completion zsh > ~/.zsh/completions/_exegol
```

Los agentes quedan conectados al plugin Spaces (sus hooks) sin pasos extra: van en
`~/.claude/settings.json`, `~/.omp/agent/config.yml` y el symlink de
`~/.config/opencode/plugins/spaces.js`, los tres gestionados por chezmoi.

macOS: `brew install chezmoi` then `chezmoi init --source ~/Projects/dotfiles_alanrz --apply`.

## Day to day

```bash
chezmoi diff                       # what would change in $HOME (target: 0)
chezmoi apply                      # write the repo to $HOME
chezmoi cd                         # git ops inside the repo
chezmoi add ~/.config/foo/config   # start tracking a new file
chezmoi re-add                     # pull edits made in $HOME back into the repo
```

Range-top workflow: change something in $HOME manually → verify with diff → readd
with `chezmoi re-add` → `git commit`. The `chezmoi re-add` step does NOT pull
credentials files (marked `create_`); they are never overwritten.

## What's here

### Hyprland (`~/.config/hypr/`)
| File | What it holds |
|------|-------------------------------|
| `monitors.lua` | HDMI-A-1 2560x1440@100 + DP-3 1920x1080@100, `GDK_SCALE` |
| `looknfeel.lua` | gaps 3 in / 6 out |
| `input.lua` | `us,latam` keyboard, toggle on Ctrl+Space |
| `bindings.lua` | SUPER+TAB ⟷ per-monitor workspace cycle (custom script) |
| `hyprland.lua` | app→workspace map, big Nautilus preview, `require("hypr.envs")` |
| `workspaces.lua` + `executable_workspace-cycle.sh` | custom per-monitor workspace cycling logic |
| `envs.lua` ⚠️ | NOT in repo (credential env). Created once via `create_private_envs.lua.tmpl` then left alone |
| `autostart.lua` | telegram, discord minimized, steam, zapfast, orca-ide, waywallen |
| `xdph.conf` | xdg-portal (screen-share) settings |

### Omarchy shell / UI (`~/.config/omarchy/`)
| File | What it holds |
|------|-------------------------------|
| `shell.json` | bar layout with plugin placement, enable/disable state |
| `omasettings.json` | Omarchy settings UI persisted state |
| `dock-settings.json`, `dock-icons.json`, `dock-pinned-macos.json` | macOS dock config |
| `plugin-manifest.json` | 15 plugins: `git` URL + enabled flag; `package` for pkg-shipped ones (flea-bin → flea-shelf) |
| `executable_restore-plugins.sh` | installs `git`-managed plugins + copies vendored ones |
| ⚠ omitted: `backgrounds/`, `themes/`, `themed/` (~1900 files) | regenerated by `omarchy theme` |
| ⚠ omitted: `hooks/` | hooks are per-machine; the ones shipped by Omarchy/plugins reinstall themselves. (ZapFast/Spotifast y Omarchy: sus apps ya leen `~/.local/state/omarchy/current/theme/` de forma nativa, sin hook) |

### Terminal (`~/.config/`)
| File | What it holds |
|------|-------------------------------|
| `starship.toml` | full custom prompt config |
| `ghostty/config` + `ghostty/shaders/cursor_tail.glsl` | font-size 10, cursor trail shader, custom scroll mult |
| `kitty/kitty.conf` | `cursor_trail 3` |

### mise (`~/.config/mise/`)
| File | What it holds |
|------|-------------------------------|
| `conf.d/prune.toml` | `upgrade.auto_prune = true`: `omarchy update` borra la versión reemplazada tras 24 h en vez de acumularlas |
| `run_after_mise-auto-prune.sh` | quita `upgrade.auto_prune` de `config.toml`: mise da prioridad a `config.toml` sobre `conf.d/`, y Omarchy la escribe en `false` al provisionar |
| ⚠ omitted: `config.toml` | lo escribe Omarchy: los wrappers de `omarchy-mise-install` corren `mise use -g` en cada arranque, así que no se versiona |

Sin el prune, cada update dejaba una versión más de cada tool (77 versiones / 20 GB
en `~/.local/share/mise`). `mise prune` borra lo pendiente de inmediato;
`mise ls --prunable` / `mise prune --dry-run` lo muestran antes.

Si tras un update vuelve a acumular: `mise settings ls | grep prune` debe decir
`true` con origen `conf.d/prune.toml`. Un `omarchy reinstall` o una migración
nueva que reescriba `config.toml` con `auto_prune = false` lo anula hasta el
siguiente `chezmoi apply` (el script `run_after_` lo vuelve a quitar).

### Zsh (`~/.zshrc`, `~/.zsh/`)
| File | What it holds |
|------|-------------------------------|
| `.zshrc` | Oh My Zsh (`sudo fzf ssh fzf-tab zsh-autosuggestions F-Sy-H`), 24 h `compinit` cache, history, keybindings, starship/zoxide init, `~/.zsh/completions` in `fpath` |
| `.zsh/aliases.zsh` | personal aliases (git, docker, yt-dlp, eza/bat, pacman, `exegol` via pipx); sourced AFTER Oh My Zsh so they win |
| `.zsh/env.zsh` | Omarchy defaults for zsh (`EDITOR`, `BROWSER`, `MANPAGER`…) + `~/.local/bin` in `PATH` |
| `.zsh/starship.zsh` | distro icon → `STARSHIP_DISTRO` (used by `starship.toml`) |
| `.zsh/functions.zsh`, `.zsh/venvchecker.zsh` | `ex` (extract anything), `venv` (toggle/create `.venv`) |
| ⚠ omitted: `~/.oh-my-zsh` + plugins | installed by hand (step 0b), updated by Oh My Zsh itself; plugins: `git -C ~/.oh-my-zsh/custom/plugins/<name> pull` |
| `.zsh/completions/_exegol` | Exegol zsh completion (`exegol completion zsh`); after updating Exegol regenerate it and `chezmoi re-add ~/.zsh/completions/_exegol` |
| ⚠ omitted: `~/.zsh_history` | public repo — command history can contain secrets |
| `.bashrc`, `.profile` (Linux-only) | Omarchy bashrc + `OPENCODE_GO_API_KEY` from opencode's `auth.json`; JetBrains Toolbox in `PATH` |

### SSH (`~/.ssh/`, age-encrypted)
| File | What it holds |
|------|-------------------------------|
| `encrypted_private_config.age` | host aliases (VPS, Tailscale, lab machines), ports, users |
| `encrypted_private_known_hosts.age` | trusted host keys |
| `encrypted_private_vps_v4cores.age` | VPS private key (also passphrase-protected by ssh-keygen) |
| `vps_v4cores.pub` | public key, plain |
| `key.txt.age` + `run_onchange_before_decrypt-private-key.sh.tmpl` | age identity encrypted with a passphrase; the script decrypts it to `~/.config/chezmoi/key.txt` (600) only if missing |

Add or update an SSH file: `chezmoi add --encrypt ~/.ssh/<file>` (never plain `chezmoi add` in this dir).
Lose the passphrase = the encrypted files can't be recovered from the repo (keep it in the password manager).

### Browsers: hardware decode (`~/*.conf`)
4 files adding the same flags: `brave-origin-flags.conf`, `chromium-flags.conf`,
`chrome-flags.conf`, `microsoft-edge-stable-flags.conf`. Without these,
Chromium reads into software decode → `dav1d` is the fallback; on Wayland
they peg an entire core playing YouTube AV1 (origin of this audit).
```
--enable-features=AcceleratedVideoDecodeLinuxGL,VaapiVideoDecodeLinuxGL,VaapiOnNvidiaGPUs
--ignore-gpu-blocklist
--disable-gpu-driver-bug-workarounds
```

### Misc apps
| File | What it holds |
|------|-------------------------------|
| `systemd/user/wallpaper-layer-top.{service,sh}` | raises waywallen video above omarchy shell background; watcher with 3 s debounce |
| `waywallen/{config.toml, waywallen.conf}` | wallpaper engine config |
| `git/config` | aliases (`lg`, `shove`…), identity |
| `local/share/applications/f5vpn-ng.desktop` | launcher del VPN (`f5vpn-ng` viene de `packages.txt`). Los flags `GDK_BACKEND=x11` + `WEBKIT_DISABLE_DMABUF_RENDERER=1` evitan los crashes de WebKitGTK al abrir su login en Wayland; sin ellos la ventana no abre |
| `claude/settings.json` | ajustes de Claude Code: hooks del plugin Spaces + `includeCoAuthoredBy: false` (sin co-autor en commits) |
| `.omp/agent/config.yml` | ajustes de omp + la extensión del plugin Spaces (`extensions:`) |
| `.config/opencode/plugins/spaces.js` (symlink) | plugin de Spaces para OpenCode (apunta al clone del plugin) |
| `.config/environment.d/10-gdk-scale.conf` | `GDK_SCALE=1` para la sesión (además de `monitors.lua`; sin esto las apps x11 arrancan al doble en pantallas scale 1) |
| `local/share/dbus-1/services/org.gnome.NautilusPreviewer.service` | fuerza `GST_GL_API=opengl3` en el previewer de Nautilus: sin esto la vista previa con Espacio falla al abrir video (error de OpenGL) |
| `hyprland.lua` etc | see above |

### pacman / makepkg (`~/.config/pacman/makepkg.conf`)

Override por usuario, sin tocar `/etc/makepkg.conf`: makepkg lo sourcea después
del de sistema (`/usr/share/makepkg/util/config.sh`), así que el `OPTIONS` de
aquí gana y sobrevive a las actualizaciones del paquete `pacman`.

Lleva `!debug` en vez de `debug`. Con `debug` + `strip`, cada build AUR emitía un
split `<pkg>-debug` que `yay -Sua` (lo que corre `omarchy update`) instalaba como
dependencia: `zed-bin-debug`, `vesktop-bin-debug`, `teams-for-linux-debug`…
Con `!debug` solo se genera el paquete real. Coste: `gdb` sin símbolos para
paquetes AUR; para un backtrace puntual, recompilar ese paquete con
`makepkg --config /etc/makepkg.conf`. Verificar tras un update:
`pacman -Qq | grep -- -debug$` debe salir vacío.

### Kali Linux VM (KVM/QEMU)

La VM probada usa QXL + SPICE, sin OpenGL ni aceleración 3D, con 4 CPU,
4096 MiB de RAM y un disco qcow2 de 40 GiB. Su red es `default` con NAT;
`host-passthrough` está activado para la CPU. La ISO es la instalación AMD64
oficial de Kali; no se guardan la ISO ni el disco de la VM en este repositorio.

En el host Arch/Omarchy, los paquetes están en `packages.txt`. Tras instalarlos:

```bash
sudo systemctl enable --now libvirtd
sudo virsh net-autostart default
sudo virsh net-start default  # omitir si ya está activa
```

Con UFW habilitado, estas son las reglas usadas para DHCP, DNS y salida NAT
por la interfaz Wi-Fi actual. Comprueba la interfaz y la subred antes de
aplicarlas en otra máquina (`ip route` y `virsh net-dumpxml default`):

```bash
sudo ufw allow in on virbr0 to any port 67 proto udp
sudo ufw allow in on virbr0 to 192.168.122.1 port 53 proto udp
sudo ufw allow in on virbr0 to 192.168.122.1 port 53 proto tcp
sudo ufw route allow in on virbr0 out on wlp7s0 from 192.168.122.0/24
```

La regla de salida permite Wi-Fi directo: **no obliga a usar F5 ni Tailscale**.
No aplicarla si la VM debe salir exclusivamente por una VPN.

En Kali con Xfce, el agente `spice-vdagent` y `xrandr`, instala los dos
archivos desde una copia de este repositorio dentro de la VM:

```bash
install -Dm755 vm/kali/kali-display-100hz "$HOME/.local/bin/kali-display-100hz"
install -Dm644 vm/kali/kali-display-100hz.desktop "$HOME/.config/autostart/kali-display-100hz.desktop"
```

El archivo `.desktop` guarda la ruta del usuario de esta VM (`/home/alan`):
si el usuario es otro, cambia `Exec` por la ruta absoluta correspondiente.
El script recrea el modo `Virtual-1` 1920 × 1080 a 99.90 Hz al iniciar sesión
y reinicia `xfdesktop` para evitar un fondo parcialmente negro. Confirma el
nombre de pantalla con `xrandr`; el modo es virtual y no garantiza 100 FPS.
Si el cursor queda desfasado tras cambiar de resolución, se corrigió con
`sudo systemctl restart spice-vdagentd`.

En Virt-Manager, `View → Scale Display → Always` escala la imagen al tamaño
de la ventana; no cambia la resolución de Kali. El redimensionado automático
no funcionó en esta instalación: el repositorio Kali configurado no ofrecía
`xserver-xorg-video-qxl`. Tampoco funcionó OpenGL/SPICE con la NVIDIA del host
(`EGL_NOT_INITIALIZED`), por lo que 3D permanece desactivado.

### System hardening & tuning (`system/`)

Ajustes de sistema en `/etc/` fuera de `$HOME` (aplicables en una máquina nueva con `sudo ./system/apply.sh`):

| File / Action | What it holds |
|------|-------------------------------|
| `system/etc/sysctl.d/99-hardening.conf` | `kernel.kptr_restrict = 2` y `fs.suid_dumpable = 0` |
| `system/etc/udev/rules.d/61-hdd-bfq.rules` | scheduler `bfq` solo para discos rotacionales HDD (`rotational==1`), manteniendo `kyber` en NVMe/SSD |
| `system/etc/systemd/journald.conf.d/10-size-limit.conf` | tope de logs `SystemMaxUse=1G` (~2.5 meses de historial) |
| `system/apply.sh` | instala los 3 archivos de arriba, habilita `pam_gnome_keyring.so` en `/etc/pam.d/sddm` (auto-desbloqueo de `login.keyring`), restringe UFW (`53317` LocalSend y `1714:1764` KDE Connect) a redes privadas LAN + Tailscale con `ufw logging off`, y fija el perfil de energía en `balanced` |

### Packages (`packages/`)
| File | What it holds |
|------|-------------------------------|
| `packages.txt` | todos los paquetes (repos + AUR), **nombres sin versión**: `yay -S --needed - < packages.txt` (yay resuelve repos primero, AUR si no está) |
| `flatpak.txt` | 4 apps de Flathub |
| `services-enabled.txt` | referencia de unidades habilitadas; ★ = las que NO trae Omarchy (tailscaled, voxtype, wallpaper-layer-top) |

## Troubleshooting (already-solved paths)

- **CPU pegged while playing YouTube?** Check for `dav1d-worker`
  threads inside the renderer. It means the browser failed to use VAAPI:
  re-check that the flags above reached the browser (`chrome://gpu` →
  `nvidia-smi -q` Decoder % > 0). The fix here: `~
  /{brave-origin,chromium,chrome,microsoft-edge-stable}-flags.conf`.
- **Wallpaper hidden behind bar?**
  `systemctl --user status wallpaper-layer-top` → restart watcher.
- **App config regenerated after update?** That's expected: only "decision"
  files are in the repo; app state regenerates. Nothing to do.
