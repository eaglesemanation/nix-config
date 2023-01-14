local M = {}

local lsp = require("emnt-nvim.lsp")
local jdtls = require("emnt-nvim.jdtls")

M.check = function()
    vim.health.report_start("LSP")
    lsp.check_health()
    vim.health.report_start("Java")
    jdtls.check_health()
end

return M
