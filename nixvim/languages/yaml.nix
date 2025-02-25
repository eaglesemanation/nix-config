{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf subtractLists;
  cfg = config.emnt.lang_support;
  langIncluded = builtins.elem "yaml" (subtractLists cfg.blacklist cfg.langs);
in
{
  config = mkIf langIncluded {
    plugins = {
      schemastore.enable = true;
      lsp.servers.yamlls = {
        enable = true;
      };
    };
  };
}
