local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.font = wezterm.font("Fira Code")
config.color_scheme = "Solarized (dark) (terminal.sexy)"

config.default_prog = { "zsh" }

return config
