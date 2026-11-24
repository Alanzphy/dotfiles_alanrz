-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })
hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 6,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })
hl.config({
  decoration = {
    rounding = 8,
  },
})

-- Omarchy 4.5 made transparency opt-in (terminals and a few apps get the
-- transparent-window tag). Restore the pre-4.5 look: every window is
-- see-through except the kinds Omarchy 4.0.6 kept opaque. Using Omarchy's own
-- tag keeps Appearance > "window opaque" and floating workspaces working.
o.window(".*", { tag = "+transparent-window" })

-- Opaque, as in 4.0.6: browsers, video and PiP, games and fullscreen apps.
local opaque_windows = {
  { tag = "chromium-based-browser" },
  { tag = "firefox-based-browser" },
  { tag = "pip" },
  "(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)",
  "steam.*",
  ".*[Rr]esolve.*",
  "com.libretro.RetroArch",
  "com.moonlight_stream.Moonlight",
  "GeForceNOW",
  "^WebcamOverlay-(small|medium|large)$",
  "org.omarchy.screensaver",
  "^Hermes$",
  "qemu",
}
for _, match in ipairs(opaque_windows) do
  o.window(match, { tag = "-transparent-window" })
end

o.window({ tag = "transparent-window" }, { opacity = "0.94 0.90" })

-- Browsers stay solid while focused, as Omarchy 4.0.6 had them.
o.window({ tag = "chromium-based-browser" }, { opacity = "1.0 0.985" })
o.window({ tag = "firefox-based-browser" }, { opacity = "1.0 0.985" })

-- Brave Origin is a Chromium web app with its own window class.
o.window("brave-origin", { tag = "-transparent-window", opacity = "1.0 0.985" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeOutQuint" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
