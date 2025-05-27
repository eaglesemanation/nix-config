local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("Iosevka Nerd Font")
config.color_scheme = "Everforest Dark (Gogh)"
config.hide_tab_bar_if_only_one_tab = true
-- Doesn't work until wezterm #4962 gets merged
config.enable_wayland = false
config.disable_default_key_bindings = true
config.keys = {
	{ key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
	{ key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
	{ key = 'P', mods = 'CTRL', action = act.ActivateCommandPalette },
	{ key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
	{ key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
}

config.default_prog = { "/usr/bin/zellij", "-l", "welcome" }
config.launch_menu = {}

if string.match(wezterm.target_triple, ".*linux.*") then
	config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
elseif string.match(wezterm.target_triple, ".*darwin.*") then
	config.window_padding = { left = 0, right = 0, top = 10, bottom = 10 }
end

return config
