{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "terraform" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues {
    inherit (pkgs) tenv;
  };
}
