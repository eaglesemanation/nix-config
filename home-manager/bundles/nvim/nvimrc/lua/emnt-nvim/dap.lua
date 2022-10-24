-- Avoids failing during bootstrap
local ok, _ = pcall(require, "dap")
if not ok then
    return
end
