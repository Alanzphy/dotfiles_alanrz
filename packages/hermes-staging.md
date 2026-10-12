# hermes — qué se respalda en el staging del cutover (2026-10-11)

`.hermes` pesa 6.9G pero 6.7G son REGENERABLES (repo desarrollo, deps, toolchains).

## Va al staging tar (indispensable, ~0.2G)

- `.env`, `.env.bak-*` — **SECRETS (issuer keys / bot tokens)**, modo 600
- `auth.json` — credenciales del agente
- `config.yaml`, `SOUL.md` — config + persona del bot
- `channel_directory.json`, `.hermes_history`, `.skills_prompt_snapshot.json`
- dirs de estado: `backups/`, `bot_relay/`, `skills/`, `pets/`, `state-snapshots/`, `logs/`

## NO va al staging (repone `hermes` solo al actualizar/instalar)

- `hermes-agent/` (git clone + node_modules + venv)
- `tools/` (ffmpeg/python/chromium/node que hermes descarga)
- `installs/`, `cache/`, `bin/`, `audio_cache/`, `bootstrap-cache/`

## Ruta de restore

1. instalar hermes (cmd del updater) → regenera agent/tools/bin
2. sobreponer los archivos de arriba desde el staging tar
3. doble seguro: `.env*` + `auth.json` viven TAMBIÉN en copia mini en el Seagate
   (大展 junto a `~/.ssh`, keys de servicios, tokens del staging).

**NUNCA commitear el contenido de `.env`/`auth.json` — son secrets.**
