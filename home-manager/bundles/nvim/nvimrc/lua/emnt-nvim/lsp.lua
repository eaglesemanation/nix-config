-- Avoids failing during bootstrap
local ok, cmp = pcall(require, "cmp")
if not ok then
    return
end

local nix_devenvs = require("emnt-nvim.nix_devenvs")

local lspconfig = require("lspconfig")
local luasnip = require("luasnip")
local lspkind = require("lspkind")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local null_ls = require("null-ls")
local lsp_lines = require("lsp_lines")

-- LSP Config
local servers = {
    yamlls = {
        on_attach = function(client, bufnr)
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

    sumneko_lua = {
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim" },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    },
}

-- Lookup table for specific language server and home-manager devenv
-- TODO: Instead of manually associating binary with env name - just dump all executables provided by enabled envs into json
local servers_nix_environments = {
    yamlls = "devops",
    terraform_fmt = "devops",
    terraformls = "devops",
    shellcheck = "devops",

    clangd = "cpp",
    cmake = "cpp",

    rust_analyzer = "rust",

    gopls = "golang",

    pylsp = "python",

    denols = "typescript",

    rnix = "nix",

    sumneko_lua = "lua",
    stylua = "lua",
}

local default_capabilities = cmp_nvim_lsp.default_capabilities()

local setup_server = function(server, config)
    local env_name = servers_nix_environments[server]

    if not config or not nix_devenvs.is_environment_enabled(env_name) then
        return
    end

    if type(config) ~= "table" then
        config = {}
    end

    config = vim.tbl_deep_extend("force", {
        capabilities = default_capabilities,
        flags = {
            debounce_text_changes = 50,
        },
    }, config)

    lspconfig[server].setup(config)
end

for server, config in pairs(servers) do
    setup_server(server, config)
end

local function null_ls_sources_nix_environment_filter(sources)
    local res = {}
    for i, source in pairs(sources) do
        local env_name = servers_nix_environments[source.name]
        if env_name == nil or nix_devenvs.is_environment_enabled(env_name) then
            res[i] = source
        end
    end
    return res
end

null_ls.setup({
    sources = null_ls_sources_nix_environment_filter({
        null_ls.builtins.formatting.trim_whitespace,
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.terraform_fmt,
        null_ls.builtins.diagnostics.shellcheck,
    }),
})

lsp_lines.setup()
-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = {
        only_current_line = true,
    },
})

-- Diagnostics Config

-- Set diganostic sign icons
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization#change-diagnostic-symbols-in-the-sign-column-gutter
local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }
for type, icon in pairs(signs) do
    local hl = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Autocomplete Config
vim.o.completeopt = "menuone,noselect"

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    formatting = {
        format = lspkind.cmp_format({
            with_text = false,
            maxwidth = 50,
        }),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
    mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        }),
        -- use Tab and shift-Tab to navigate autocomplete menu
        ["<Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end,
        ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end,
    },
})

-- Remaps
vim.keymap.set("n", "<leader>sf", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>sd", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>sh", vim.lsp.buf.hover)
