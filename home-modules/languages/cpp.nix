{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (builtins.elem "cpp" config.emnt.lang_support.langs) {
  home.packages = lib.mkMerge [
    (builtins.attrValues { inherit (pkgs) clang-tools cmake-language-server; })
  ];
}
