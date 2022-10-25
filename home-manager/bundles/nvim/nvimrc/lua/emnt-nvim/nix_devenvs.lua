-- Parses a JSON file dumped into nvim config dir by nix, specifically home-manager.
-- Will be used to dynamically enable support for language servers, debuggers, etc.

local M = {}

local function parse_envs_provides()
    local envs_path = vim.fs.normalize("$XDG_DATA_HOME/nix/dev_envs_provides.json")
    local ok, envs_json = pcall(vim.fn.readfile, envs_path)
    if not ok then
        return {}
    end
    local envs
    ok, envs = pcall(vim.fn.json_decode, envs_json)
    if not ok then
        return {}
    end
    return envs
end

local provided_bins = parse_envs_provides()

M.is_binary_provided = function(bin)
    if provided_bins == {} then
        -- Failed to find/parse provides file, assume that everything needed is already installed
        -- In this case worst case scenario - there will be some errors about needed binaries missing
        -- Otherwise bunch of useful functionality will be disabled for no good reason
        return true
    end
    for _, provided_bin in pairs(provided_bins) do
        if bin == provided_bin then
            return true
        end
    end
    return false
end

return M
