-- Avoids failing during bootstrap
local ok, telescope = pcall(require, "telescope")
if not ok then
    return
end

local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

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
    },
})

telescope.load_extension("fzf")

-- git_files with fallback for find_files
local function project_files()
    local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
    if in_git_repo then
        builtin.git_files()
    else
        builtin.find_files()
    end
end

-- File pickers
vim.keymap.set("n", "<leader>ff", project_files)
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")

-- LSP Binds
vim.keymap.set("n", "<leader>sd", "<cmd>Telescope lsp_definitions<cr>")
vim.keymap.set("n", "<leader>sr", "<cmd>Telescope lsp_references<cr>")
