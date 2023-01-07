local function ensure_packer()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

local function packer_setup(use)
    -- Self-manage plugin manager
    use("wbthomason/packer.nvim")

    ----
    -- Movements
    ----
    use("tpope/vim-surround")
    use("tpope/vim-repeat")
    -- Additional targets that feel like vanilla vim
    use("wellle/targets.vim")
    use({
        -- Move to any visible position in 4 keystrokes max
        "ggandor/leap.nvim",
        config = function()
            require("leap").add_default_mappings()
        end,
    })
    use({ "anuvyklack/hydra.nvim", as = "hydra" })

    -- Fuzzy search
    use({
        "nvim-telescope/telescope.nvim",
        as = "telescope",
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
            { "nvim-telescope/telescope-ui-select.nvim" },
        },
        config = function()
            require("emnt-nvim.telescope")
        end,
    })

    -- Language specific configs such as errorformat
    use("sheerun/vim-polyglot")

    -- Changes background color of RGB values
    use({
        "norcalli/nvim-colorizer.lua",
        ft = { "css", "html" },
        config = function()
            require("colorizer").setup()
        end,
    })
    -- Automatically generates LSP colors for legacy colorschemes
    use("folke/lsp-colors.nvim")
    use({
        "lifepillar/vim-solarized8",
        config = function()
            vim.cmd.colorscheme("solarized8_flat")
        end,
    })
    use("kyazdani42/nvim-web-devicons")
    use({
        "nvim-lualine/lualine.nvim",
        requires = {
            { "kyazdani42/nvim-web-devicons", opt = true },
        },
        config = function()
            require("lualine").setup({})
        end,
    })
    -- Keep cursor position when window below is opened
    use({
        "luukvbaal/stabilize.nvim",
        config = function()
            require("stabilize").setup()
        end,
    })

    ----
    -- Git integration
    ----
    use("tpope/vim-fugitive")
    use("tpope/vim-git")
    use({
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    })
    use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })

    -- Simplified language servers config
    use({
        "neovim/nvim-lspconfig",
        as = "lspconfig",
        requires = {
            -- Java specific configuration with additional features
            { "mfussenegger/nvim-jdtls" },
            -- Progress bar for language server indexing
            {
                "j-hui/fidget.nvim",
                config = function()
                    require("fidget").setup({
                        window = { blend = 0 },
                    })
                end,
            },
            -- Configures lua language server for neovim specific api
            {
                "folke/neodev.nvim",
                config = function()
                    require("neodev").setup({
                        override = function(root_dir, library)
                            if #(vim.fs.find({ "nix-config" }, { path = root_dir, upward = true })) > 0 then
                                library.enabled = true
                                library.plugins = true
                            end
                        end,
                    })
                end,
            },
            -- Autocompletion integration
            { "hrsh7th/cmp-nvim-lsp" },
        },
    })
    -- Integration layer between linters/formatters and LSP
    use("jose-elias-alvarez/null-ls.nvim")

    -- Debugger
    use({
        "mfussenegger/nvim-dap",
        requires = {
            { "rcarriga/nvim-dap-ui" },
        },
        after = { "hydra" },
        config = function()
            require("emnt-nvim.dap")
        end,
    })

    -- Testing frameworks integration
    use({
        "nvim-neotest/neotest",
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-neotest/neotest-go" },
            { "rouge8/neotest-rust" },
        },
        after = { "hydra", "treesitter" },
        config = function()
            require("emnt-nvim.neotest")
        end,
    })

    -- Improved syntax support
    use({
        "nvim-treesitter/nvim-treesitter",
        as = "treesitter",
        requires = {
            -- Keep current context at the top of buffer (for example function name)
            { "nvim-treesitter/nvim-treesitter-context" },
            -- Interactive playground for treesitter queries
            { "nvim-treesitter/playground" },
        },
        run = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = "all",
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
            require("treesitter-context").setup()
        end,
    })
    use({ "towolf/vim-helm", ft = { "helm" } })

    -- Snippets
    use({
        "L3MON4D3/LuaSnip",
        as = "luasnip",
        requires = {
            -- Autocompletion
            { "saadparwaiz1/cmp_luasnip" },
        },
    })
    -- Autocompletion
    use({
        "hrsh7th/nvim-cmp",
        requires = {
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-omni" },
        },
        after = {
            "lspconfig",
            "luasnip",
            "telescope",
            "hydra",
        },
        config = function()
            require("emnt-nvim.lsp")
        end,
    })

    -- Diagnostics list
    use({
        "folke/trouble.nvim",
        requires = { { "kyazdani42/nvim-web-devicons", opt = true } },
        config = function()
            require("trouble").setup({})
        end,
    })

    -- Improved NetRW
    use("tpope/vim-vinegar")

    -- LaTeX integration
    use({
        "lervag/vimtex",
        ft = { "tex" },
        config = function()
            vim.g.vimtex_view_method = "general"
            vim.g.vimtex_view_general_viewer = "evince"

            vim.g.vimtex_compiler_method = "latexmk"
            -- https://github.com/neovim/neovim/issues/12544
            vim.api.nvim_set_var("vimtex_compiler_latexmk", { build_dir = "./build" })

            vim.api.nvim_create_augroup("VimTeX", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = "VimTeX",
                pattern = { "tex" },
                callback = function()
                    require("cmp").setup.buffer({ sources = { { name = "omni" } } })
                end,
            })
        end,
    })

    use("dstein64/vim-startuptime")

    -- Setup on first boot
    if packer_bootstrap then
        require("packer").sync()
    end
end

require("packer").startup({
    packer_setup,
    config = {
        profile = {
            enable = true,
            threshold = 1,
        },
    },
})
