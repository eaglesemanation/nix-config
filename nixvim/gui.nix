{ lib, helpers, ... }:
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
      settings.integrations.telescope = true;
    };
    diffview.enable = true;

    rainbow-delimiters.enable = true;
    web-devicons.enable = true;
    # Search glyphs from nerdfonts
    nerdy.enable = true;
    # Fuzzy searcher
    telescope = {
      enable = true;
      extensions = {
        file-browser.enable = true;
        ui-select.enable = true;
        fzf-native.enable = true;
      };
      settings = {
        defaults = {
          mappings.i = {
            "<esc>" = helpers.mkRaw "require('telescope.actions').close";
          };
        };
      };
    };
    # Bookmarks git folders as projects
    project-nvim = {
      enable = true;
      enableTelescope = true;
    };
    auto-session.enable = true;

    which-key.enable = true;
  };

  keymaps =
    let
      inherit (import ./lib.nix { inherit lib; }) modeKeys;
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (
      modeKeys [ "n" ] {
        "<leader>ff" = {
          action = "<cmd>Telescope find_files hidden=true find_command=fd,--type,f,--color,never<cr>";
          options.desc = "Fuzzy search for files recursively";
        };
        "<leader>fg" = {
          action = "<cmd>Telescope live_grep<cr>";
          options.desc = "Grep through contents of files";
        };
        "<leader>fb" = {
          action = "<cmd>Telescope file_browser cwd=%:p:h<cr>";
          options.desc = "Open a file browser";
        };
        "<leader>fs" = {
          action = "<cmd>Telescope aerial<cr>";
          options.desc = "Search for symbols";
        };
        "<leader>fS" = {
          action = "<cmd>SessionSearch<cr>";
          options.desc = "Search for sessions";
        };
        "<leader>fd" = "<cmd>Telescope diagnostics<cr>";
        "<leader>fp" = "<cmd>Telescope projects<cr>";
        "<leader>fn" = "<cmd>Telescope nerdy<cr>";

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
