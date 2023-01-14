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
        {
            "f",
            function()
                builtin.find_files({ hidden = true })
            end,
            { desc = "project [f]iles" },
        },
        {
            "g",
            function()
                builtin.live_grep({ additional_args = { "--hidden" } })
            end,
            { desc = "[g]rep" },
        },
        { "b", builtin.buffers, { desc = "[b]uffers" } },
        { "s", builtin.treesitter, { desc = "[s]ymbols" } },
    },
})
