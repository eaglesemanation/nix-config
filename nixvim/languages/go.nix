{
  lib,
  config,
  ...
}:
let
  inherit (import ../lib.nix { inherit lib; }) mkIfLang;
in
{
  config = mkIfLang config.emnt.lang_support "go" {
    plugins = {
      lsp.servers.gopls = {
        enable = true;
      };
      neotest.adapters.golang = {
        enable = true;
      };
      dap-go.enable = true;
    };
  };
}
