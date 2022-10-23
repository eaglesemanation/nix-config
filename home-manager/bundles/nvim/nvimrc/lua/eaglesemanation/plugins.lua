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
            require("colorizer").setup()
        end,
    })
    use("kyazdani42/nvim-web-devicons")
    use({
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
        config = function()
            require("lualine").setup({})
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
            require("stabilize").setup()
        end,
    })

    -- Git integration
    use("tpope/vim-fugitive")
    use("tpope/vim-git")
    use({
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    })

    -- Simplified language servers config
    use("neovim/nvim-lspconfig")
    use("jose-elias-alvarez/null-ls.nvim")

    -- Debugger
    use({
        "mfussenegger/nvim-dap",
        requires = {
            { "leoluz/nvim-dap-go" },
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
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
        config = function()
            require("trouble").setup({})
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
