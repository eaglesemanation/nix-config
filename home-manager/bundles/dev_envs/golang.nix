{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.golang;
in {
  options.bundles.dev_env.golang.enable =
    mkEnableOption "Go lang development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues { inherit (pkgs) go gopls delve; };
  };
}
