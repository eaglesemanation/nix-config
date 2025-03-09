{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "python" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues {
    inherit (pkgs) uv;
  };
}
