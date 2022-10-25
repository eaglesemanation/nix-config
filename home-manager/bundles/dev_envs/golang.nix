{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.golang;

  golang_pkgs = builtins.attrValues { inherit (pkgs) go gopls delve; };

in {
  options.bundles.dev_env.golang.enable =
    mkEnableOption "Go lang development environment";

  config = mkIf cfg.enable {
    home.packages = golang_pkgs;
    bundles.dev_envs.provides = derivations_bins golang_pkgs;
  };
}
