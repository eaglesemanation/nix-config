{
  lib,
  helpers,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    attrNames
    filterAttrs
    removeSuffix
    hasSuffix
    ;

  langFilenames = attrNames (
    filterAttrs (n: v: v == "regular" && (hasSuffix ".nix" n)) (builtins.readDir ./languages)
  );
  langs = builtins.map (removeSuffix ".nix") langFilenames;
in
{
  options.emnt.lang_support = {
    langs = mkOption {
      type = types.listOf (types.enum langs);
      description = "List of languages to enable support for";
      default = langs;
    };
    blacklist = mkOption {
      type = types.listOf (types.enum langs);
      description = "List of languages to exclude from support";
      default = [ ];
    };
  };

  imports = builtins.map (n: ./languages + "/${n}.nix") langs;

  config = {
    plugins = {
      # Language syntax parsing
      treesitter = {
        enable = true;
        folding = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          incremental_selection.enable = true;
        };
      };
      treesitter-textobjects.enable = true;
      guess-indent.enable = true;
      aerial.enable = true;

      # Language specific functionality in a server
      lsp.enable = true;
      # Formatters integration
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = # Lua
            ''
              function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                  return
                end
                return { timeout_ms = 200, lsp_fallback = true }
              end
            '';
          default_format_opts.lsp_format = "fallback";
        };
      };

      # Execute project specific tasks
      overseer.enable = true;

      # Attaching a debugger to a process
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
      dap.enable = true;

      # Running unit tests
      neotest.enable = true;
    };

    keymaps =
      let
        inherit (import ./lib.nix { inherit lib; }) modeKeys;
      in
      helpers.keymaps.mkKeymaps { options.silent = true; } (
        modeKeys [ "n" ] {
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

          "<leader>tt" = "<cmd>Neotest run<cr>";
          "<leader>td" = "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<cr>";
          "<leader>tf" = "<cmd>Neotest run file<cr>";
          "<leader>tT" = "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<cr>";
          "<leader>ts" = "<cmd>Neotest stop<cr>";
          "<leader>tu" = "<cmd>Neotest summary<cr><cmd>Neotest output-panel<cr>";
        }
      );
  };
}
