{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "typst" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues { inherit (pkgs) typst; };
}
