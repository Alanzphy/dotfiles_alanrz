local monitors = {
  { monitor = "HDMI-A-1", from = 1, to = 5 },
  { monitor = "DP-3", from = 6, to = 10 },
}

for _, desk in ipairs(monitors) do
  for n = desk.from, desk.to do
    hl.workspace_rule({
      workspace = tostring(n),
      monitor = desk.monitor,
      persistent = true,
    })
  end
end
