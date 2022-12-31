-- Avoids failing during bootstrap
local ok, neotest = pcall(require, "neotest")
if not ok then
    return
end

local hydra = require("hydra")

-- get neotest namespace (api call creates or returns namespace)
local neotest_ns = vim.api.nvim_create_namespace("neotest")
-- substitute white space characters with single space character, improves readability for neotest-go
vim.diagnostic.config({
    virtual_text = {
        format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
        end,
    },
}, neotest_ns)

neotest.setup({
    adapters = {
        require("neotest-go")({
            experemental = {
                test_table = true,
            },
        }),
    },
})

hydra({
    name = "Testing",
    mode = "n",
    body = "<leader>t",
    config = {
        -- Blue hydra dies as soon as any of it heads is called
        color = "blue",
    },
    heads = {
        { "r", neotest.run.run, { desc = "[r]un a test under cursor" } },
        {
            "R",
            function()
                neotest.run.run(vim.fn.getcwd())
            end,
            { desc = "[R]un all tests in CWD" },
        },
    },
})
