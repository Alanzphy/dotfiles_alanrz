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
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
require("hypr.workspaces")

-- Place these apps on their dedicated workspaces on the secondary monitor.
o.window("^spotifast$", { workspace = "7" })
o.window("^orca$", { workspace = "6" })
o.window("^steam$", { workspace = "8" })
o.window("^zapfast$", { workspace = "9" })
o.window("^discord$", { workspace = "9" })

-- Larger Nautilus preview (spacebar) than the default 875x600 float.
-- Matches the tag too so it runs after Omarchy's floating-window size rule.
o.window({ class = "org.gnome.NautilusPreviewer", tag = "floating-window" }, { size = { 1100, 760 } })

-- Load settings written by OmaSettings (omasettings:managed).
require("hypr.omasettings")
