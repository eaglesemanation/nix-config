{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "nix" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues { inherit (pkgs) statix; };
}
