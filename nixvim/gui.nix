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

    # Git integration
    gitsigns.enable = true;
    neogit = {
      enable = true;
      settings.integrations.telescope = true;
    };
    diffview.enable = true;

    rainbow-delimiters.enable = true;
    web-devicons.enable = true;
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
            "<esc>" = helpers.mkRaw ''
              require("telescope.actions").close
            '';
          };
        };
      };
    };
    # Bookmarks git folders as projects
    project-nvim = {
      enable = true;
      enableTelescope = true;
    };

    which-key.enable = true;
  };

  keymaps =
    let
      inherit (import ./lib.nix { inherit lib; }) modeKeys;
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (
      modeKeys [ "n" ] {
        "<leader>ff" = "<cmd>Telescope find_files hidden=true<cr>";
        "<leader>fg" = "<cmd>Telescope live_grep<cr>";
        "<leader>fb" = "<cmd>Telescope file_browser cwd=%:p:h<cr>";
        "<leader>fs" = {
          action = "<cmd>Telescope aerial<cr>";
          options.desc = "Search for symbols";
        };
        "<leader>fd" = "<cmd>Telescope diagnostics<cr>";
        "<leader>fp" = "<cmd>Telescope projects<cr>";

        "<leader>gg" = "<cmd>Neogit<cr>";
        "<leader>gb" = "<cmd>Neogit branch<cr>";
        "<leader>gd" = "<cmd>DiffviewOpen<cr>";
      }
    );
}
