local function jdtls_setup()
    -- Wrapper script for jdtls provided by Nix
    if vim.fn.executable("jdt-language-server") ~= 1 then
        print("jdt-language-server is missing")
        return
    end

    local cache_path = vim.env.XDG_CACHE_HOME
    if cache_path == nil then
        cache_path = vim.env.HOME .. "/.cache"
    end

    local project_root = vim.fs.dirname(vim.fs.find({ ".gradlew", ".git", "mvnw" }, { upward = true })[1])
    if project_root == nil then
        print("could not find project root, set up one of those: gradle, maven, git")
        return
    end
    local project_name = vim.fn.fnamemodify(project_root, ":p:h:t")

    -- Look for vscode extensions for DAP support
    local bundles = {}
    for _, ext_path in pairs({ "~/.nix-profile/share/vscode/extensions", "~/.vscode/extensions" }) do
        local abs_ext_path = vim.fs.normalize(ext_path)
        if vim.fn.isdirectory(abs_ext_path) then
            local debug_glob = abs_ext_path .. "/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar"
            local test_glob = abs_ext_path .. "/vscjava.vscode-java-test/server/com.microsoft.java.test.plugin-*.jar"
            vim.list_extend(bundles, vim.split(vim.fn.glob(debug_glob, true), "\n", {}), 1, #bundles)
            vim.list_extend(bundles, vim.split(vim.fn.glob(test_glob, true), "\n", {}), 1, #bundles)
            break
        end
    end

    local config = {
        cmd = {
            "jdt-language-server",
            "-configuration",
            cache_path .. "/jdtls/config",
            "-data",
            cache_path .. "/jdtls/workspace/" .. project_name,
        },
        init_options = {
            bundles = bundles,
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

vim.api.nvim_create_augroup("nvim-jdtls", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "java" },
    group = "nvim-jdtls",
    callback = jdtls_setup,
})
