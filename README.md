# dotfiles_alanrz

Dotfiles for Linux (Omarchy) and macOS, managed with [chezmoi](https://chezmoi.io).

The source lives in `home/` (see `.chezmoiroot`). OS-specific files are filtered
by `home/.chezmoiignore`: Linux-only paths are skipped on macOS and vice versa.

## New machine

```bash
# Linux (Omarchy): omarchy pkg add chezmoi   |   macOS: brew install chezmoi
git clone <repo-url> ~/Projects/dotfiles_alanrz
chezmoi init --source ~/Projects/dotfiles_alanrz --apply
```

## Day to day

```bash
chezmoi add ~/.config/foo/config   # start tracking a file
chezmoi diff                       # what would change in $HOME
chezmoi re-add                     # pull edits made in $HOME back into the repo
chezmoi apply                      # write the repo to $HOME
chezmoi cd                         # open a shell in the repo (git commit/push)
```

When adding an OS-specific path, list it under the matching block in
`home/.chezmoiignore`.

## What's here

| File | OS | Why |
|------|----|-----|
| `.config/hypr/hyprland.lua` | Linux | Hyprland overrides, incl. larger Nautilus preview (1100x760) |
| `.local/share/dbus-1/services/org.gnome.NautilusPreviewer.service` | Linux | `GST_GL_API=opengl3` so video previews work on NVIDIA (fixes `EGL_BAD_CONTEXT` / "Failed to initialize OpenGL with Gtk") |
