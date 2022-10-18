{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.cpp;
in {
  options.bundles.dev_env.cpp.enable = mkEnableOption "C/C++ development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) clang-tools cmake-language-server;
    };
  };
}
