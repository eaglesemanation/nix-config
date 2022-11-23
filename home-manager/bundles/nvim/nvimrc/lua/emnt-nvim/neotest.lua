-- Avoids failing during bootstrap
local ok, neotest = pcall(require, "neotest")
if not ok then
    return
end

neotest.setup({
    adapters = {
        require("neotest-rust"),
    },
})
