-- Parses a JSON file dumped into nvim config dir by nix, specifically home-manager.
-- Will be used to dynamically enable support for language servers, debuggers, etc.

local M = {}

local function parse_environments()
    local envs_path = vim.fs.normalize("$XDG_CONFIG_HOME/nvim/devenvs.json")
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

local envs = parse_environments()

M.is_environment_enabled = function(env_name)
    for _, env in pairs(envs) do
        if env == env_name then
            return true
        end
    end
    return false
end

return M
