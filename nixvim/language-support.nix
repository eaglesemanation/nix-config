{
  lib,
  helpers,
  config,
  ...
}@inputs:
let
  inherit (lib)
    mkOption
    mkMerge
    mkIf
    mkDefault
    types
    attrNames
    filterAttrs
    removeSuffix
    hasSuffix
    ;

  langFilenames = attrNames (
    filterAttrs (n: v: v == "regular" && (hasSuffix ".nix" n)) (builtins.readDir ./languages)
  );
  definedLangs = builtins.map (removeSuffix ".nix") langFilenames;

  cfg = config.emnt.lang_support;
in
{
  options.emnt.lang_support = {
    enable = mkOption {
      type = types.listOf (types.enum definedLangs);
      description = "List of languages to enable support for";
      default = definedLangs;
    };
    disable = mkOption {
      type = types.listOf (types.enum definedLangs);
      description = "List of languages to exclude from support";
      default = [ ];
    };
    langs = mkOption {
      type = types.listOf (types.enum definedLangs);
      readOnly = true;
    };
    homeManagerSupport = mkOption {
      type = types.bool;
      description = "If enabled - reuses home-manager emnt.lang_support as nixvim config";
      default = builtins.hasAttr "hmConfig" inputs;
    };
  };

  imports = builtins.map (n: ./languages + "/${n}.nix") definedLangs;

  config = {
    warnings = lib.nixvim.mkWarnings "emnt.lang_support" [
      (
        let
          nixvimUniqueLangs = lib.subtractLists inputs.hmConfig.emnt.lang_support.definedLangs definedLangs;
        in
        {
          when = cfg.homeManagerSupport && builtins.length nixvimUniqueLangs != 0;
          message = "nixvim defines those languages, but home-manager doesn't: [${builtins.toString nixvimUniqueLangs}]";
        }
      )
      (
        let
          homemanagerUniqueLangs = lib.subtractLists definedLangs inputs.hmConfig.emnt.lang_support.definedLangs;
        in
        {
          when = cfg.homeManagerSupport && builtins.length homemanagerUniqueLangs != 0;
          message = "home-manager defines those languages, but nixvim doesn't: [${builtins.toString homemanagerUniqueLangs}]";
        }
      )
    ];

    emnt.lang_support = mkMerge [
      (mkIf cfg.homeManagerSupport (
        let
          inherit (inputs.hmConfig.emnt.lang_support) enable disable;
        in
        {
          enable = mkDefault (lib.intersectLists definedLangs enable);
          disable = mkDefault (lib.intersectLists definedLangs disable);
        }
      ))
      { langs = lib.subtractLists cfg.disable cfg.enable; }
    ];

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
      # Import project specific LSP config from .vscode/settings.json
      neoconf.enable = true;
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
      compiler.enable = true;

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

          "<leader>dc" = "<cmd>DapContinue<cr>";
          "<leader>db" = "<cmd>DapToggleBreakpoint<cr>";
          "<leader>dB" = {
            action = "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Enter breakpoint condition: '))<cr>";
            options.desc = "Set a conditional breakpoint";
          };
          "<leader>du" = "<cmd>lua require('dapui').toggle()<cr>";
          "<leader>ds" = "<cmd>DapStepOver<cr>";
          "<leader>di" = "<cmd>DapStepInto<cr>";
          "<leader>do" = "<cmd>DapStepOut<cr>";
          "<leader>dt" = "<cmd>DapTerminate<cr>";
        }
      );
  };
}
