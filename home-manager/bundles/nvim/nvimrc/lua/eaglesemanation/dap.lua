local ok, dap = pcall(require, "dap")
if not ok then
    return
end

require("dap-go").setup()
