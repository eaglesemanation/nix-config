{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (import ../lib.nix { inherit lib; }) mkIfLang;
in
{
  config = mkIfLang config.emnt.lang_support "sql" {
    plugins = {
      lsp.servers = {
        sqls.enable = true;
      };
      conform-nvim.settings = {
        formatters_by_ft = {
          sql = [ "sqlfluff" ];
        };
        formatters = {
          sqlfluff = lib.getExe pkgs.sqlfluff;
        };
      };
    };
  };
}
