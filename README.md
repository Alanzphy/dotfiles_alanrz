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

## New machine (Linux / Omarchy)

```bash
# 0. install Omarchy per its docs, then:
omarchy pkg add chezmoi
git clone https://github.com/Alanzphy/dotfiles_alanrz ~/Projects/dotfiles_alanrz
chezmoi init --source ~/Projects/dotfiles_alanrz --apply

# 0b. zsh: Oh My Zsh + plugins are NOT in the repo (they self-update via git)
RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
P=~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions $P/zsh-autosuggestions
git clone https://github.com/Aloxaf/fzf-tab $P/fzf-tab
git clone https://github.com/z-shell/F-Sy-H $P/F-Sy-H
chsh -s /usr/bin/zsh                     # needs zsh, zsh-completions, thefuck pkgs

# 1. restore Omarchy shell plugins (15; reads ~/.config/omarchy/plugin-manifest.json)
~/.config/omarchy/restore-plugins.sh

# 2. flea (file manager + shelf plugin): comes from a package, not a plugin clone
omarchy pkg aur add flea-bin && flea --default

# 3. keys: fill the 3 slots and never worry again
#    ~/.config/hypr/envs.lua                       (TODO-REEMPLAZAR-KEY)
#    ~/.config/environment.d/30-ai-usagebar.conf   (TODO-REEMPLAZAR-KEY)
#    ~/.config/ai-usagebar/config.toml             (plugin re-chmods 600 itself)
#    then: omarchy-restart-shell (hyprland re-read envs.lua = plugin config)

# 4. theme (re-generates backgrounds/, themed/, shell updates)
omarchy theme set "<your-theme>"
```

## Tailscale after a fresh install (cutover)

```bash
# Prefer the same identity (no login): stage kept it alive
sudo scripts/restore-tailscale.sh restore    # reads /mnt/Extra/staging/tailscale
# If the state was lost:
sudo scripts/restore-tailscale.sh fresh      # browser login with Alanzphy@ then rename device
```

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
| `hooks/theme-set.d/spotifast-theme`, `zapfast-theme` | push Omarchy palette into these apps while running |
| ⚠ omitted: `backgrounds/`, `themes/`, `themed/` (~1900 files) | regenerated by `omarchy theme` |
| ⚠ omitted: `hooks/post-update.d/{install-voxtype,setup-agent,setup-fingerprint}` | first-run provisioning — fresh Omarchy recreates |

### Terminal (`~/.config/`)
| File | What it holds |
|------|-------------------------------|
| `starship.toml` | full custom prompt config |
| `ghostty/config` + `ghostty/shaders/cursor_tail.glsl` | font-size 10, cursor trail shader, custom scroll mult |
| `kitty/kitty.conf` | `cursor_trail 3` |

### Zsh (`~/.zshrc`, `~/.zsh/`)
| File | What it holds |
|------|-------------------------------|
| `.zshrc` | Oh My Zsh (`sudo fzf zoxide ssh zsh-autosuggestions F-Sy-H fzf-tab`), history, keybindings, starship/thefuck/zoxide init, `~/.zsh/completions` in `fpath` |
| `.zsh/aliases.zsh` | personal aliases (git, docker, yt-dlp, eza/bat, pacman, `exegol` via pipx); sourced AFTER Oh My Zsh so they win |
| `.zsh/env.zsh` | Omarchy defaults for zsh (`EDITOR`, `BROWSER`, `MANPAGER`…) + `~/.local/bin` in `PATH` |
| `.zsh/starship.zsh` | distro icon → `STARSHIP_DISTRO` (used by `starship.toml`) |
| `.zsh/functions.zsh`, `.zsh/venvchecker.zsh` | `ex` (extract anything), `venv` (toggle/create `.venv`) |
| ⚠ omitted: `~/.oh-my-zsh` + plugins | installed by hand (step 0b), updated by Oh My Zsh itself; plugins: `git -C ~/.oh-my-zsh/custom/plugins/<name> pull` |
| `.zsh/completions/_exegol` | Exegol zsh completion (`exegol completion zsh`); after updating Exegol regenerate it and `chezmoi re-add ~/.zsh/completions/_exegol` |
| ⚠ omitted: `~/.zsh_history` | public repo — command history can contain secrets |
| `.bashrc`, `.profile` (Linux-only) | Omarchy bashrc + `OPENCODE_GO_API_KEY` from opencode's `auth.json`; JetBrains Toolbox in `PATH` |

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
| `ai-usagebar/config.toml` (create_once) | plugin secrets slot + provider toggles |
| `hyprland.lua` etc | see above |

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
