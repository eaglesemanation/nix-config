{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "go" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers.gopls = {
      enable = true;
    };
    neotest.adapters.golang = {
      enable = true;
    };
    dap-go.enable = true;
  };
}
