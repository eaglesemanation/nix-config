{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (builtins.elem "typescript" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers = {
      ts_ls.enable = true;
      eslint.enable = true;
    };
    neotest.adapters.vitest.enable = true;
    conform-nvim.settings = {
      javascript = ["prettierd"];
      formatters.prettierd.command = lib.getExe pkgs.prettierd;
    };
  };
}
