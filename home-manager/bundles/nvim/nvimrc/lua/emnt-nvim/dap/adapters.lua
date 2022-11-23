local dap = require("dap")

if vim.fn.executable("lldb-vscode") == 1 then
    dap.adapters.lldb = {
        type = "executable",
        command = vim.fn.exepath("lldb-vscode"),
        name = "lldb",
    }
end
