local M = {}

function M.nnoremap(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true })
end

return M
