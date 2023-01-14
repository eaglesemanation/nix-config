local M = {}

local utils = require("emnt-nvim.utils")

local function extensions_dir_path()
    for _, ext_path in pairs({ "~/.nix-profile/share/vscode/extensions", "~/.vscode/extensions" }) do
        local abs_ext_path = vim.fs.normalize(ext_path)
        if vim.fn.isdirectory(abs_ext_path) then
            return abs_ext_path
        end
    end
    return nil
end

local function extension_path(ext_root, ext_name)
    local ext_glob = ext_root
        .. "/vscjava.vscode-java-"
        .. ext_name
        .. "/server/com.microsoft.java."
        .. ext_name
        .. ".plugin-*.jar"
    local matches = vim.fn.glob(ext_glob, true, true)
    if #matches == 1 then
        return matches[1]
    else
        return nil
    end
end

local function extensions_list()
    local ext_root = extensions_dir_path()
    if ext_root == nil then
        return {}
    end
    local extensions = {}
    local test = extension_path(ext_root, "test")
    local debug = extension_path(ext_root, "debug")
    if test ~= nil then
        table.insert(extensions, test)
    end
    if debug ~= nil then
        table.insert(extensions, debug)
    end
    return extensions
end

local function jdtls_setup()
    -- Wrapper script for jdtls provided by Nix
    if vim.fn.executable("jdt-language-server") ~= 1 then
        return
    end

    local cache_path = vim.env.XDG_CACHE_HOME
    if cache_path == nil then
        cache_path = vim.env.HOME .. "/.cache"
    end

    local project_root = vim.fs.dirname(utils.find_upwards({ ".gradlew", ".git", "mvnw" }))
    if project_root == nil then
        print("could not find project root, set up one of those: gradle, maven, git")
        return
    end
    local project_name = vim.fn.fnamemodify(project_root, ":p:h:t")

    local config = {
        cmd = {
            "jdt-language-server",
            "-configuration",
            cache_path .. "/jdtls/config",
            "-data",
            cache_path .. "/jdtls/workspace/" .. project_name,
        },
        init_options = {
            bundles = extensions_list(),
        },
        on_attach = function(_, _)
            -- Set up DAP adapter
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
        end,
        settings = { java = { configuration = { runtimes = {} } } },
    }
    if vim.env.JAVA_8_HOME ~= nil then
        table.insert(config.settings.java.configuration.runtimes, {
            name = "JavaSE-8",
            path = vim.env.JAVA_8_HOME,
        })
    end
    if vim.env.JAVA_11_HOME ~= nil then
        table.insert(config.settings.java.configuration.runtimes, {
            name = "JavaSE-11",
            path = vim.env.JAVA_11_HOME,
        })
    end
    if vim.env.JAVA_17_HOME ~= nil then
        table.insert(config.settings.java.configuration.runtimes, {
            name = "JavaSE-17",
            path = vim.env.JAVA_17_HOME,
        })
    end
    require("jdtls").start_or_attach(config)
end

M.check_health = function()
    local server = "jdt-language-server"
    if vim.fn.executable(server) == 1 then
        vim.health.report_ok(server .. " installed")
    else
        vim.health.report_error(server .. " not installed")
    end
    local ext_root = extensions_dir_path()
    if ext_root == nil then
        vim.health.report_error("could not find vscode extensions dir")
    else
        if extension_path(ext_root, "test") ~= nil then
            vim.health.report_ok("java test extension installed")
        else
            vim.health.report_error("could not find java test extension")
        end
        if extension_path(ext_root, "debug") ~= nil then
            vim.health.report_ok("java debug extension installed")
        else
            vim.health.report_error("could not find java debug extension")
        end
    end
end

M.setup = function()
    vim.api.nvim_create_augroup("nvim-jdtls", {})
    vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "java" },
        group = "nvim-jdtls",
        callback = jdtls_setup,
    })
end

return M
