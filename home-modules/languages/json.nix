{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "json" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues {
    inherit (pkgs) jq;
  };
}
