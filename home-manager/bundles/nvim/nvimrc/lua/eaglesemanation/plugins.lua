local ensure_packer = function()
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

require("packer").startup(function(use)
    -- Self-manage plugin manager
    use("wbthomason/packer.nvim")

    -- Movements
    use("tpope/vim-surround")
    use("tpope/vim-repeat")

    -- Lua impl of filetype.vim
    use("nathom/filetype.nvim")

    -- Visual
    use({
        "norcalli/nvim-colorizer.lua",
        ft = { "css", "html" },
        config = function()
            -- Avoids failing during bootstrap
            local ok, colorizer = pcall(require, "colorizer")
            if ok then
                colorizer.setup()
            end
        end,
    })
    use("kyazdani42/nvim-web-devicons")
    use({
        "nvim-lualine/lualine.nvim",
        requires = { { "kyazdani42/nvim-web-devicons", opt = true } },
        config = function()
            local ok, lualine = pcall(require, "lualine")
            if ok then
                lualine.setup({})
            end
        end,
    })
    use({
        "ishan9299/nvim-solarized-lua",
        config = function()
            local _, _ = pcall(vim.cmd, "colorscheme solarized")
        end,
    })
    use({
        -- Keep cursor position when window below is opened
        "luukvbaal/stabilize.nvim",
        config = function()
            local ok, stabilize = pcall(require, "stabilize")
            if ok then
                stabilize.setup()
            end
        end,
    })

    -- Git integration
    use("tpope/vim-fugitive")
    use("tpope/vim-git")
    use({
        "lewis6991/gitsigns.nvim",
        config = function()
            local ok, gitsigns = pcall(require, "gitsigns")
            if ok then
                gitsigns.setup()
            end
        end,
    })
    use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })

    -- Simplified language servers config
    use("neovim/nvim-lspconfig")
    use("jose-elias-alvarez/null-ls.nvim")

    -- Debugger
    use({
        "mfussenegger/nvim-dap",
        requires = {
            {
                "leoluz/nvim-dap-go",
                opt = true,
                ft = { "go", "gomod" },
            },
        },
        config = function()
            require("eaglesemanation.dap")
        end,
    })

    -- Improved syntax support
    use({
        "nvim-treesitter/nvim-treesitter",
        requires = {
            { "nvim-treesitter/nvim-treesitter-context" },
        },
        run = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        config = function()
            require("eaglesemanation.treesitter")
        end,
    })
    use("towolf/vim-helm")

    -- Autocompletion
    use({
        "L3MON4D3/LuaSnip",
        as = "luasnip",
    })
    use({
        "hrsh7th/nvim-cmp",
        requires = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-omni" },
            { "onsails/lspkind-nvim" },
            { "saadparwaiz1/cmp_luasnip", after = { "luasnip" } },
        },
        config = function()
            require("eaglesemanation.lsp")
        end,
    })

    -- Diagnostics list
    use({
        "folke/trouble.nvim",
        requires = { { "kyazdani42/nvim-web-devicons", opt = true } },
        config = function()
            local ok, trouble = pcall(require, "trouble")
            if ok then
                trouble.setup({})
            end
        end,
    })

    -- Fuzzy search
    use({
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
        },
        config = function()
            require("eaglesemanation.telescope")
        end,
    })

    -- Improved NetRW
    use("tpope/vim-vinegar")

    -- LaTeX integration
    use({
        "lervag/vimtex",
        ft = { "tex" },
        config = function()
            require("eaglesemanation.vimtex")
        end,
    })

    -- Setup on first boot
    if packer_bootstrap then
        require("packer").sync()
        vim.cmd("packadd packer.nvim")
    end
end)
