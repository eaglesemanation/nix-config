{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.python;

  python_pkgs = builtins.attrValues {
    inherit (pkgs) python3;
    inherit (pkgs.python3Packages) python-lsp-server;
  };

in {
  options.bundles.dev_env.python.enable =
    mkEnableOption "Python development environment";

  config = mkIf cfg.enable {
    home.packages = python_pkgs;
    bundles.dev_envs.provides = derivations_bins python_pkgs;
  };
}
