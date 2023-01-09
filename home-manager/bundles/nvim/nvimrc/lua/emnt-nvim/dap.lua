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

vim.api.nvim_create_augroup("dap_dynamic_config", { clear = true })
-- TODO: Figure out how to reduce amount of tries to load launch.json while keeping it easy to use
vim.api.nvim_create_autocmd({ "BufEnter, BufWinEnter" }, {
    group = "dap_dynamic_config",
    callback = function()
        local vscode_dir = vim.fs.find(".vscode", { upwards = true })[1]
        if vscode_dir == nil then
            return
        end
        if vim.fn.filereadable(vscode_dir .. "/launch.json") == 0 then
            return
        end
        require("dap.ext.vscode").load_launchjs(vscode_dir .. "/launch.json")
    end,
})

local function set_conditional_breakpoint()
    vim.ui.input({
        prompt = "Breakpoint condition:",
    }, function(condition)
        dap.set_breakpoint(condition)
    end)
end

hydra({
    name = "Debug",
    mode = "n",
    body = "<leader>d",
    config = {
        invoke_on_body = true,
    },
    heads = {
        { "d", dap.continue, { exit = true, desc = "run" } },
        { "b", dap.toggle_breakpoint, { desc = "[b]reakpoint" } },
        { "B", set_conditional_breakpoint, { desc = "conditional [B]reakpoint" } },
        { "s", dap.step_into, { desc = "[s]tep into" } },
        { "n", dap.step_over, { desc = "[n]ext" } },
        { "u", dapui.toggle, { exit = true, desc = "toddle [u]i" } },
    },
})
