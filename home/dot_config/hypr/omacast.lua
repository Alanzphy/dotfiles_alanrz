-- rebind, not bind: Omarchy 4.5 binds Alt+Space to dictation by default, and a
-- plain o.bind would fire both. Dictation stays on Super+Ctrl+X and Right Alt.
o.rebind("ALT + SPACE", "omacast launcher", hl.dsp.global("omacast:toggle"))

