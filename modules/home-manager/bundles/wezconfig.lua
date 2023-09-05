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

config.font = wezterm.font("FiraCode Nerd Font")
config.color_scheme = "Solarized (dark) (terminal.sexy)"

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 64

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    { key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }) },

    -- Splitting into panes
    { key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Navigating panes
    { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

    -- Navigating tabs
    { key = "[", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },

    -- Indexing starting from 1 for easier shortcut access
    { key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },
}

config.default_prog = { "zsh" }

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
