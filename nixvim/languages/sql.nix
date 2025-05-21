{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (builtins.elem "sql" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers.postgres_lsp.enable = true;
  };
}
