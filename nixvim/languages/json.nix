{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "json" config.emnt.lang_support.langs) {
  plugins = {
    schemastore = {
      enable = true;
      json.enable = true;
    };
    lsp.servers.jsonls = {
      enable = true;
    };
  };
}
