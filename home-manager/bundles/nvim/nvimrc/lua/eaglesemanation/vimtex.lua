vim.g.vimtex_view_method = "general"
vim.g.vimtex_view_general_viewer = "evince"

vim.g.vimtex_compiler_method = "latexmk"
-- https://github.com/neovim/neovim/issues/12544
vim.api.nvim_set_var("vimtex_compiler_latexmk", { build_dir = "./build" })
vim.cmd([[
    augroup VimTeX
        autocmd!
        autocmd FileType tex
        \ lua require('cmp').setup.buffer { sources = { { name = 'omni' } } }
    augroup END
]])
