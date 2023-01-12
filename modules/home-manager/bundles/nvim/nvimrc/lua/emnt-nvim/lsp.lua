local M = {}

-- Avoids failing during bootstrap
local ok, cmp = pcall(require, "cmp")
if not ok then
    return
end

local lspconfig = require("lspconfig")
local luasnip = require("luasnip")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local null_ls = require("null-ls")

local hydra = require("hydra")
local cmd = require("hydra.keymap-util").cmd

-- LSP Config
local servers = {
    yamlls = {
        on_attach = function(_, bufnr)
            if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
                vim.diagnostic.disable()
            end
        end,
    },
    terraformls = true,

    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
        },
    },
    cmake = true,

    rust_analyzer = true,
    gopls = true,
    pylsp = true,
    denols = true,
    rnix = true,
    -- Configured through nvim-jdtls
    jdtls = false,

    sumneko_lua = {
        settings = {
            Lua = {
                completion = { callSnippet = "Replace" },
                telemetry = { enable = false },
                workspace = { library = { "${3rd}/luassert/library" } },
            },
        },
    },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local server_exists = function(server, config)
    local server_name = lspconfig[server].document_config.default_config.cmd[1]
    if type(config) == "table" and config.cmd ~= nil and #config.cmd > 0 then
        server_name = config.cmd[1]
    end

    return vim.fn.executable(server_name) == 1
end

local setup_server = function(server, config)
    if type(config) == "boolean" and not config then
        return
    end

    if not server_exists(server, config) then
        return
    end

    if type(config) ~= "table" then
        config = {}
    end

    config = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 50,
        },
    }, config)

    lspconfig[server].setup(config)
end

local null_ls_sources = {
    null_ls.builtins.formatting.trim_whitespace,
    null_ls.builtins.formatting.trim_newlines,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.terraform_fmt,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.golangci_lint,
}

local function null_ls_source_exists(source)
    return vim.fn.executable(source._opts.command) == 1
end

local function null_ls_filter_executable()
    local res = {}
    for _, source in pairs(null_ls_sources) do
        if null_ls_source_exists(source) then
            table.insert(res, source)
        end
    end
    return res
end

local function setup_servers()
    for server, config in pairs(servers) do
        setup_server(server, config)
    end
    null_ls.setup({
        sources = null_ls_filter_executable(),
    })
end

-- Diagnostics Config
local function setup_diagnostics()
    -- Set diganostic sign icons
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization#change-diagnostic-symbols-in-the-sign-column-gutter
    local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }
    for type, icon in pairs(signs) do
        local hl = "LspDiagnosticsSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
end

-- Autocomplete Config
local cmp_conf = {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        -- use Tab and shift-Tab to navigate autocomplete menu
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
}

local function setup_cmp()
    vim.o.completeopt = "menuone,noselect"
    cmp.setup(cmp_conf)
end

local hydra_conf = {
    name = "LSP",
    mode = "n",
    body = "<leader>s",
    config = {
        -- Blue hydra dies as soon as any of it heads is called
        color = "blue",
    },
    heads = {
        { "f", vim.lsp.buf.format, { desc = "[f]ormat" } },
        { "d", cmd("Telescope lsp_definitions"), { desc = "[d]efinitions" } },
        { "D", cmd("Telescope lsp_references"), { desc = "references" } },
        { "h", vim.lsp.buf.hover, { desc = "[h]over popup" } },
        { "r", vim.lsp.buf.rename, { desc = "[r]ename" } },
        { "a", vim.lsp.buf.code_action, { desc = "code [a]ction" } },
    },
}

M.check_health = function()
    for server, config in pairs(servers) do
        if type(config) == "boolean" and not config then
            goto continue
        end
        if server_exists(server, config) then
            vim.health.report_ok(server .. " installed")
        else
            vim.health.report_error(server .. " not installed")
        end
        ::continue::
    end
    for _, source in pairs(null_ls_sources) do
        if null_ls_source_exists(source) then
            vim.health.report_ok(source._opts.command .. " installed")
        else
            vim.health.report_error(source._opts.command .. " not installed")
        end
    end
end

M.setup = function()
    setup_servers()
    setup_cmp()
    setup_diagnostics()
    hydra(hydra_conf)
end

return M
