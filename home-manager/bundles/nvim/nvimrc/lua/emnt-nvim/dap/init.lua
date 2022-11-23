-- Avoids failing during bootstrap
local ok, dap = pcall(require, "dap")
if not ok then
    return
end
local dapui = require("dapui")

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

vim.keymap.set("n", "<leader>dd", run_dap)
vim.keymap.set("n", "<leader>dD", function()
    vim.ui.input({
        prompt = "Enter arguments: ",
    }, function(args)
        run_dap(args)
    end)
end)

vim.keymap.set("n", "<leader>du", dapui.toggle)
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>ds", dap.step_into)
vim.keymap.set("n", "<leader>dn", dap.step_over)
