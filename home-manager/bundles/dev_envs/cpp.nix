{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.cpp;

  cpp_pkgs =
    builtins.attrValues { inherit (pkgs) clang-tools cmake-language-server; };
in {
  options.bundles.dev_env.cpp.enable =
    mkEnableOption "C/C++ development environment";

  config = mkIf cfg.enable {
    home.packages = cpp_pkgs;
    bundles.dev_envs.provides = derivations_bins cpp_pkgs;
  };
}
