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

    which-key.enable = true;
  };

  keymaps =
    let
      modeKeys = mode: lib.attrsets.mapAttrsToList (key: action: { inherit key mode action; });
    in
    helpers.keymaps.mkKeymaps { options.silent = true; } (
      modeKeys [ "n" ] {
        "<leader>ff" = "<cmd>Telescope find_files hidden=true<cr>";
        "<leader>fg" = "<cmd>Telescope live_grep<cr>";
        "<leader>fb" = "<cmd>Telescope file_browser<cr>";
        "<leader>fs" = "<cmd>Telescope aerial<cr>";
        "<leader>fd" = "<cmd>Telescope diagnostics<cr>";

        "<leader>sd" = "<cmd>Telescope lsp_definitions<cr>";
        "<leader>sD" = "<cmd>Telescope lsp_references<cr>";
        "<leader>si" = "<cmd>Telescope lsp_implementations<cr>";
        "<leader>st" = "<cmd>Telescope lsp_type_definitions<cr>";

        "<leader>se" = "<cmd>lua vim.diagnostic.open_float()<cr>";
        "<leader>sf" = "<cmd>lua require('conform').format()<cr>";
        "<leader>sF" = "<cmd>let b:disable_autoformat = 1<cr>";
        "<leader>sh" = "<cmd>lua vim.lsp.buf.hover()<cr>";
        "<leader>sr" = "<cmd>lua vim.lsp.buf.rename()<cr>";
        "<leader>sa" = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      }
    );
}
