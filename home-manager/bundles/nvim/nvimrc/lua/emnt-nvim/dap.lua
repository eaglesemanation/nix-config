-- Avoids failing during bootstrap
local ok, dap = pcall(require, "dap")
if not ok then
    return
end
local dapui = require("dapui")
local hydra = require("hydra")

-- Use default config for now
dapui.setup()

if vim.fn.executable("lldb-vscode") == 1 then
    dap.adapters.lldb = {
        type = "executable",
        command = vim.fn.exepath("lldb-vscode"),
        name = "lldb",
    }
end
if vim.fn.executable("dlv") == 1 then
    dap.adapters.delve = {
        type = "server",
        port = "${port}",
        executable = {
            command = "dlv",
            args = { "dap", "-l", "127.0.0.1:${port}" },
        },
    }
end

-- Start debugging session
local function run_dap(args)
    args = args or {}
    dap.continue()
    dapui.open({})
end

hydra({
    name = "Debugging",
    mode = "n",
    body = "<leader>d",
    heads = {
        { "d", run_dap, { desc = "run" } },
        { "u", dapui.toggle, { desc = "toddle [u]i" } },
        { "b", dap.toggle_breakpoint, { desc = "[b]reakpoint" } },
        { "s", dap.step_into, { desc = "[s]tep into" } },
        { "n", dap.step_over, { desc = "[n]ext" } },
    },
})
