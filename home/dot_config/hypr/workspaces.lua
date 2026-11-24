-- Omarchy 4.5 gives every monitor its own workspaces 1-10 (Super+N acts on the
-- focused monitor). Internally each monitor owns a block of ten ids, recorded in
-- ~/.local/state/omarchy/monitor-workspaces: LG (HDMI-A-1) = 1-10, Xiaomi
-- (DP-3) = 11-20.
--
-- Pinning each block to its monitor only matters for window rules that name a
-- workspace id (hypr/hyprland.lua): without it Hyprland creates that workspace
-- on whichever monitor has focus, and Omarchy then renumbers it into that
-- monitor's block. Monitors are matched by description, like Omarchy does, so a
-- connector rename doesn't break it. Not persistent: the bar shows 1-5 per
-- monitor via Spaces' persistentWorkspaces instead, so Super+Tab skips empties.
--
-- Pre-4.5 version: hypr/backups/pre-4.5-workspaces/.
local monitors = {
  { monitor = "desc:LG Electronics LG IPS QHD 507TFEN1C660", from = 1, to = 10 },
  { monitor = "desc:Xiaomi Corporation P24FBA-RAGL 5438700042700", from = 11, to = 20 },
}

for _, desk in ipairs(monitors) do
  for n = desk.from, desk.to do
    hl.workspace_rule({ workspace = tostring(n), monitor = desk.monitor })
  end
end
