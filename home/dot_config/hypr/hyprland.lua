-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.envs")
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Load settings written by OmaControl (omacontrol:managed).
-- It belongs above the toggles below: those turn the laptop
-- display off with a monitor rule, and a rule of ours read
-- afterwards would replace it and put the display back on.
require("hypr.omacontrol")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
require("hypr.workspaces")

-- Omarchy 4.5 floats and centers the Brave Bitwarden extension window itself
-- (default/hypr/apps/bitwarden.lua). `center` only positions it at map time;
-- the extension then resizes itself to its natural size, which leaves it
-- off-center. Do not add a `size` rule: the handler below re-centers once the
-- client's size has settled, then stops.

local bitwarden_popup = {
  class = "brave-nngceckbapebfimnlniiiahkandclblb-Default",
  interval = 100, -- ms between size checks while the client settles
  stable_checks = 2, -- consecutive equal sizes required before centering
  max_checks = 20, -- hard stop (~2 s) so a client resize loop cannot pin it
  pending = {},
}

local function window_by_address(address)
  for _, window in ipairs(hl.get_windows()) do
    if window.address == address then
      return window
    end
  end
end

local function window_size(window)
  local size = window.size
  return tostring(size[1] or size.x or 0) .. "x" .. tostring(size[2] or size.y or 0)
end

local function center_bitwarden(address, last_size, stable, checks, centered_size)
  hl.timer(function()
    local window = window_by_address(address)

    -- Closed or no longer floating (e.g. user tiled it): stop watching.
    if not window or not window.floating then
      bitwarden_popup.pending[address] = nil
      return
    end

    local size = window_size(window)
    local stable_count = size == last_size and stable + 1 or 0

    -- Centre only after the client's size stops changing, and only when that
    -- size differs from the one already centred. Size changes are client-driven,
    -- so a manual move (which keeps the same size) is never undone.
    if stable_count >= bitwarden_popup.stable_checks and size ~= centered_size then
      hl.dispatch(hl.dsp.window.center({ window = window }))
      centered_size = size
    end

    if checks >= bitwarden_popup.max_checks then
      bitwarden_popup.pending[address] = nil
      return
    end

    center_bitwarden(address, size, stable_count, checks + 1, centered_size)
  end, { timeout = bitwarden_popup.interval, type = "oneshot" })
end

hl.on("window.open", function(window)
  if window.class ~= bitwarden_popup.class then
    return
  end

  if bitwarden_popup.pending[window.address] then
    return
  end

  bitwarden_popup.pending[window.address] = true
  center_bitwarden(window.address, window_size(window), 0, 0, nil)
end)

-- Dedicated workspaces. Omarchy 4.5 gives every monitor its own block of ten
-- (HDMI-A-1 = ids 1-10, DP-3 = ids 11-20; see hypr/workspaces.lua), so DP-3's
-- slots 1-4 (Super+1..4 with DP-3 focused) are ids 11-14.
o.window("^brave-origin$", { workspace = "1" })
o.window("^org\\.mozilla\\.Thunderbird$", { workspace = "5" })
o.window("^orca$", { workspace = "11" })
o.window("^spotifast$", { workspace = "12" })
o.window("^steam$", { workspace = "13" })
o.window("^zapfast$", { workspace = "14" })
o.window("^discord$", { workspace = "14" })

-- Larger Nautilus preview (spacebar) than the default 875x600 float.
-- Matches the tag too so it runs after Omarchy's floating-window size rule.
o.window({ class = "org.gnome.NautilusPreviewer", tag = "floating-window" }, { size = { 1100, 760 } })


require("hypr.omacast")
