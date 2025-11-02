{
  lib,
  helpers,
  ...
}:
{
  plugins = {
    # Show LSP status in the corner
    fidget.enable = true;
    lualine = {
      enable = true;
      settings = {
        sections = {
          lualine_c = [
            (
              (helpers.listToUnkeyedAttrs [ "filename" ])
              // {
                path = 1;
              }
            )
          ];
          lualine_x = [
            (helpers.listToUnkeyedAttrs [ "overseer" ])
          ];
        };
      };
    };
    # Pane management + multiplexer integration
    smart-splits = {
      enable = true;
      settings = {
        # Assumes that it's WezTerm, so have to override
        multiplexer_integration = "zellij";
      };
    };

    # Git integration
    gitsigns.enable = true;
    neogit = {
      enable = true;
      settings.integrations.mini_pick = true;
    };
    diffview.enable = true;

    rainbow-delimiters.enable = true;
    web-devicons.enable = true;
    mini = {
      enable = true;
      modules = {
        pick = {
          mappings = {
            choose_all = {
              char = "<C-q>";
              func = lib.nixvim.mkRaw ''
                function()
                  local mappings = MiniPick.get_picker_opts().mappings
                  vim.api.nvim_input(mappings.mark_all .. mappings.choose_marked)
                end
              '';
            };
          };
        };
        extra = { };
      };
      luaConfig.post = # lua
        ''
          vim.ui.select = require('mini.pick').ui_select
        '';
    };
    oil.enable = true;
    auto-session.enable = true;

    which-key.enable = true;
  };

  colorschemes.everforest = {
    enable = true;
    settings.background = "hard";
  };

  keymaps =
    let
      inherit (import ./lib.nix { inherit lib; }) modeKeys;
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (
      modeKeys [ "n" ] {
        "<leader>ff" = {
          action = "<cmd>Pick files<cr>";
          options.desc = "Fuzzy search for files recursively";
        };
        "<leader>fg" = {
          action = "<cmd>Pick grep_live<cr>";
          options.desc = "Grep through contents of files";
        };
        "<leader>fb" = {
          action = "<cmd>Oil<cr>";
          options.desc = "Open a file browser";
        };
        "<leader>fs" = {
          action = "<cmd>SessionSearch<cr>";
          options.desc = "Search for sessions";
        };
        "<leader>fd" = "<cmd>Pick diagnostic scope='current'<cr>";

        "<leader>gg" = "<cmd>Neogit<cr>";
        "<leader>gb" = "<cmd>Neogit branch<cr>";
        "<leader>gd" = "<cmd>DiffviewOpen<cr>";

        # Window operations
        "<A-h>" = helpers.mkRaw "require('smart-splits').resize_left";
        "<A-j>" = helpers.mkRaw "require('smart-splits').resize_down";
        "<A-k>" = helpers.mkRaw "require('smart-splits').resize_up";
        "<A-l>" = helpers.mkRaw "require('smart-splits').resize_right";
        "<C-h>" = helpers.mkRaw "require('smart-splits').move_cursor_left";
        "<C-j>" = helpers.mkRaw "require('smart-splits').move_cursor_down";
        "<C-k>" = helpers.mkRaw "require('smart-splits').move_cursor_up";
        "<C-l>" = helpers.mkRaw "require('smart-splits').move_cursor_right";

        "<leader>\\" = "<cmd>vsplit<cr>";
        "<leader>-" = "<cmd>split<cr>";
      }
    );

  plugins.which-key.settings.spec = [
    {
      __unkeyed = "<leader>f";
      group = "Fuzzy finder";
      icon = " ";
    }
    {
      __unkeyed = "<leader>g";
      group = "Git integration";
    }
  ];
}
