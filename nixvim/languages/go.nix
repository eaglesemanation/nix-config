{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf subtractLists;
  cfg = config.emnt.lang_support;
  langIncluded = builtins.elem "go" (subtractLists cfg.blacklist cfg.langs);
in
{
  config = mkIf langIncluded {
    plugins = {
      lsp.servers.gopls = {
        enable = true;
      };
    };
  };
}
