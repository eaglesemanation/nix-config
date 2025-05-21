{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "rust" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues {
    inherit (pkgs) cargo-nextest cargo-cross;
  };
}
