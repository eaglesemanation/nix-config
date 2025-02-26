{
  lib,
  config,
  ...
}:
let
  inherit (import ../lib.nix { inherit lib; }) mkIfLang;
in
{
  config = mkIfLang config.emnt.lang_support "json" {
    plugins = {
      schemastore = {
        enable = true;
        json.enable = true;
      };
      lsp.servers.jsonls = {
        enable = true;
      };
    };
  };
}
