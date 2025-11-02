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

  inherit (lib.nixvim) mkRaw;

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
      treesitter-context = {
        enable = true;
        settings.max_lines = 5;
      };
      guess-indent.enable = true;

      # Language specific functionality in a server
      lsp = {
        enable = true;
        servers.typos_lsp.enable = true;
      };
      # Linter integration into LSP
      lint.enable = true;
      # Import project specific LSP config from .vscode/settings.json
      neoconf.enable = true;
      # Formatters integration
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = # lua
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
      overseer = {
        enable = true;
        settings.templates = [ "builtin" ];
      };

      # Attaching a debugger to a process
      dap = {
        enable = true;
        signs = {
          dapBreakpoint = {
            text = "󰄯";
            texthl = "Red";
          };
          dapBreakpointCondition = {
            text = "󰟃";
            texthl = "Red";
          };
          dapBreakpointRejected = {
            text = "";
            texthl = "Red";
          };
          dapLogPoint = {
            text = "";
            texthl = "Green";
          };
          dapStopped = {
            text = "";
            texthl = "Green";
          };
        };
      };
      dap-view = {
        enable = true;
        settings = {
          auto_toggle = true;
          winbar.controls.enabled = true;
        };
      };

      # Running unit tests
      neotest = {
        enable = true;
        settings.consumers.overseer = mkRaw "require('neotest.consumers.overseer')";
      };
    };

    extraFiles."lua/overseer/component/nixvim/run_on_output.lua".text = # lua
      ''
        return {
          desc = "Executes lua code once when a matching line is printed into stdout",
          params = {
            pattern = {
              type = "string",
              name = "Match pattern",
            },
            callback = {
              type = "opaque",
              name = "Function to call on match",
              validate = function(callback)
                return type(callback) == "function"
              end,
            },
            oneshot = {
              type = "boolean",
              name = "Only run callback after first match",
              default = false,
            }
          },
          editable = false,
          constructor = function(params)
            return {
              executed = false,
              on_init = function(self, task)
                self.executed = false
              end,
              on_output_lines = function(self, task, lines)
                if params.oneshot and self.executed then
                  return
                end
                for _, line in ipairs(lines) do
                  if line:match(params.pattern) then
                    params.callback(line, params.pattern)
                    self.executed = true
                  end
                end
              end,
            }
          end
        }
      '';

    keymaps =
      let
        inherit (import ./lib.nix { inherit lib; }) modeKeys;
      in
      helpers.keymaps.mkKeymaps { options.silent = true; } (
        modeKeys [ "n" ] {
          "<leader>sd" = "<cmd>Pick lsp scope='definition'<cr>";
          "<leader>sD" = "<cmd>Pick lsp scope='references'<cr>";
          "<leader>si" = "<cmd>Pick lsp scope='implementation'<cr>";
          "<leader>st" = "<cmd>Pick lsp scope='type_definition'<cr>";

          "<leader>se" = "<cmd>lua vim.diagnostic.open_float()<cr>";
          "<leader>sf" = {
            action = "<cmd>lua require('conform').format()<cr>";
            options.desc = "Format current buffer";
          };
          "<leader>sF" = {
            action = "<cmd>let b:disable_autoformat = 1<cr>";
            options.desc = "Disable format on save for current buffer";
          };
          "<leader>sh" = "<cmd>lua vim.lsp.buf.hover()<cr>";
          "<leader>sr" = "<cmd>lua vim.lsp.buf.rename()<cr>";
          "<leader>sa" = "<cmd>lua vim.lsp.buf.code_action()<cr>";

          "<leader>tt" = {
            action = "<cmd>Neotest run<cr>";
            options.desc = "Run a test under cursor";
          };
          "<leader>td" = {
            action = "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<cr>";
            options.desc = "Attach a debugger to a test under cursor";
          };
          "<leader>tf" = {
            action = "<cmd>Neotest run file<cr>";
            options.desc = "Run all tests in current file";
          };
          "<leader>tT" = {
            action = "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<cr>";
            options.desc = "Run all tests in current working directory";
          };
          "<leader>ts" = {
            action = "<cmd>Neotest stop<cr>";
            options.desc = "Stop running tests";
          };
          "<leader>tu" = {
            action = "<cmd>Neotest summary<cr><cmd>Neotest output-panel<cr>";
            options.desc = "Show Neotest summary and output panels";
          };

          "<leader>dr" = "<cmd>OverseerRun<cr>";
          "<leader>dc" = "<cmd>DapContinue<cr>";
          "<leader>db" = "<cmd>DapToggleBreakpoint<cr>";
          "<leader>dB" = {
            action = "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Enter breakpoint condition: '))<cr>";
            options.desc = "Set a conditional breakpoint";
          };
          "<leader>du" = "<cmd>DapViewToggle<cr>";
          "<leader>ds" = "<cmd>DapStepOver<cr>";
          "<leader>di" = "<cmd>DapStepInto<cr>";
          "<leader>do" = "<cmd>DapStepOut<cr>";
          "<leader>dt" = "<cmd>DapTerminate<cr>";
        }
      );

    plugins.which-key.settings.spec = [
      {
        __unkeyed = "<leader>s";
        group = "LSP server commands";
        icon = " ";
      }
      {
        __unkeyed = "<leader>t";
        group = "Testing and Tabs";
        icon = "󰙨 ";
      }
      {
        __unkeyed = "<leader>d";
        group = "Debugging";
        icon = " ";
      }
    ];
  };
}
