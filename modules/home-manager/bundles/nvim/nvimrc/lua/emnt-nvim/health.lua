local M = {}

local lsp = require("emnt-nvim.lsp")

M.check = function()
    vim.health.report_start("emnt-config report")
    lsp.check_health()
end

return M
