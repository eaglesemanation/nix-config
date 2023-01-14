-- Avoids failing during bootstrap
local ok, hydra = pcall(require, "hydra")
if not ok then
    return
end

local hint = [[
 Arrow^^^^^^   Select region with <C-v> 
 ^ ^ _K_ ^ ^   _f_: surround it with box
 _H_ ^ ^ _L_
 ^ ^ _J_ ^ ^                      _<Esc>_
]]

hydra({
    name = "Draw [b]ox diagrams",
    hint = hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            border = "rounded",
        },
        on_enter = function()
            vim.o.virtualedit = "all"
        end,
    },
    mode = "n",
    body = "<leader>b",
    heads = {
        { "H", "<C-v>h:VBox<CR>" },
        { "J", "<C-v>j:VBox<CR>" },
        { "K", "<C-v>k:VBox<CR>" },
        { "L", "<C-v>l:VBox<CR>" },
        { "f", ":VBox<CR>", { mode = "v" } },
        { "<Esc>", nil, { exit = true } },
    },
})
