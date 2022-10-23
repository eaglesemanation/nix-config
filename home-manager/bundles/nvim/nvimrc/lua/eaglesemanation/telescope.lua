local M = {}

local ok, telescope = pcall(require, "telescope")
if not ok then
    return
end

local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

local utils = require("eaglesemanation.utils")

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
function M.project_files()
    local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
    if in_git_repo then
        builtin.git_files()
    else
        builtin.find_files()
    end
end

-- File pickers
utils.nnoremap("<leader>ff", '<cmd>lua require("eaglesemanation.telescope").project_files()<cr>')
utils.nnoremap("<leader>fg", "<cmd>Telescope live_grep<cr>")
utils.nnoremap("<leader>fb", "<cmd>Telescope buffers<cr>")

-- LSP Binds
utils.nnoremap("<leader>sd", "<cmd>Telescope lsp_definitions<cr>")
utils.nnoremap("<leader>sr", "<cmd>Telescope lsp_references<cr>")

return M
