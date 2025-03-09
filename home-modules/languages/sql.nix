{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "sql" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues {
    inherit (pkgs) usql;
  };
}
