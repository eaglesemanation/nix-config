{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "python" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers = {
      pyright.enable = true;
      ruff.enable = true;
    };
  };
}
