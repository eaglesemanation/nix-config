-- Avoids failing during bootstrap
local ok, telescope = pcall(require, "telescope")
if not ok then
    return
end

local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

local hydra = require("hydra")
local cmd = require("hydra.keymap-util").cmd

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
    pickers = {
        lsp_code_actions = {
            theme = "cursor",
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["ui-select"] = {
            themes.get_dropdown({}),
        },
    },
})

telescope.load_extension("fzf")
telescope.load_extension("ui-select")

-- git_files with fallback for find_files
local function project_files()
    local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
    if in_git_repo then
        builtin.git_files()
    else
        builtin.find_files()
    end
end

hydra({
    name = "Fuzzy finder",
    mode = "n",
    body = "<leader>f",
    config = {
        -- Blue hydra dies as soon as any of it heads is called
        color = "blue",
    },
    heads = {
        -- File pickers
        { "f", project_files, { desc = "project [f]iles" } },
        { "g", cmd("Telescope live_grep"), { desc = "[g]rep" } },
        { "b", cmd("Telescope buffers"), { desc = "[b]uffers" } },
    },
})
