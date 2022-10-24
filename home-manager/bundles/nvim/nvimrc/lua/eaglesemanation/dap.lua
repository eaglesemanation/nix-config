-- Avoids failing during bootstrap
local ok, _ = pcall(require, "dap")
if not ok then
    return
end

local dap_go
ok, dap_go = pcall(require, "dap-go")
if ok then
    dap_go.setup()
end
