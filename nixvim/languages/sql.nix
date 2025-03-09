{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (builtins.elem "sql" config.emnt.lang_support.langs) {
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
}
