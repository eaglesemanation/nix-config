local wezterm = require("wezterm")
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

config.enable_wayland = false

config.font = wezterm.font("Iosevka Nerd Font")
config.color_scheme = "Solarized (dark) (terminal.sexy)"

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 64
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{ key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }) },

	-- Splitting into panes
	{ key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Navigating panes
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

	-- Navigating tabs
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "{", mods = "LEADER", action = wezterm.action.MoveTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "}", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
}

for i = 1, 8 do
	table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = wezterm.action.ActivateTab(i) })
end

config.default_prog = { "/usr/bin/zsh" }
config.launch_menu = {}

local os_shell = nil
if string.match(wezterm.target_triple, ".*linux.*") then
	os_shell = "bash"
elseif string.match(wezterm.target_triple, ".*darwin.*") then
	os_shell = "zsh"
end

if os_shell ~= nil then
	table.insert(config.launch_menu, {
		label = "New Tab (No Nix)",
		args = {
			os_shell,
			"-c",
			-- Looks for any mention of .nix-profile or /nix in PATH and removes it
			"/usr/bin/env PATH=$(awk -v RS=: -v ORS=: '!/\\/\\.nix-profile|^\\/nix/' <<< \"$PATH\" | sed 's/:$//') "
				.. os_shell,
		},
	})
end

---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
	local pane = tab.active_pane
	local proccess = basename(pane.foreground_process_name)

	local title = tab.tab_title
	if not title or #title == 0 then
		title = pane.title
	end

	return " <" .. (tab.tab_index + 1) .. ": " .. proccess .. "> " .. title .. " "
end)

return config
