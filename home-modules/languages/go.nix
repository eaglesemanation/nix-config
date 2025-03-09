{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (builtins.elem "go" config.emnt.lang_support.langs) {
  home.packages = builtins.attrValues {
    inherit (pkgs)
      go
      golangci-lint
      delve
      ;
  };
}
