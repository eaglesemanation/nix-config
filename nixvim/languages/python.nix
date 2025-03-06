{
  lib,
  config,
  ...
}:
let
  inherit (import ../lib.nix { inherit lib; }) mkIfLang;
in
{
  config = mkIfLang config.emnt.lang_support "python" {
    plugins = {
      lsp.servers = {
        pyright.enable = true;
        ruff.enable = true;
      };
    };
  };
}
