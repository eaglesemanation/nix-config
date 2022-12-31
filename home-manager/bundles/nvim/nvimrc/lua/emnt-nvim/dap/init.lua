-- Avoids failing during bootstrap
local ok, dap = pcall(require, "dap")
if not ok then
    return
end
local dapui = require("dapui")
local hydra = require("hydra")

-- Use default config for now
dapui.setup()

-- Configure every available adapter
require("emnt-nvim.dap.adapters")

local dynamic_dap_config = nil
vim.api.nvim_create_augroup("dynamic_dap_config", {})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = "dynamic_dap_config",
    callback = function()
        dynamic_dap_config = nil
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = "dynamic_dap_config",
    pattern = { "*.rs" },
    callback = function()
        dynamic_dap_config = require("emnt-nvim.dap.rust").run
    end,
})

-- Start debugging session
local function run_dap(args)
    args = args or {}
    if dynamic_dap_config == nil then
        dap.continue()
        dapui.open({})
    else
        dynamic_dap_config({}, function()
            dapui.open({})
        end)
    end
end

hydra({
    name = "Debugging",
    mode = "n",
    body = "<leader>d",
    heads = {
        { "d", run_dap, { desc = "run" } },
        {
            "D",
            function()
                vim.ui.input({
                    prompt = "Enter arguments: ",
                }, function(args)
                    run_dap(args)
                end)
            end,
            { desc = "run with args" },
        },
        { "u", dapui.toggle, { desc = "toddle [u]i" } },
        { "b", dap.toggle_breakpoint, { desc = "[b]reakpoint" } },
        { "s", dap.step_into, { desc = "[s]tep into" } },
        { "n", dap.step_over, { desc = "[n]ext" } },
    },
})
