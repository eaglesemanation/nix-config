{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.devops;

  devops_pkgs = builtins.attrValues {
    inherit (pkgs) shellcheck terraform terraform-ls yaml-language-server;
  };

in {
  options.bundles.dev_env.devops.enable = mkEnableOption "DevOps environment";

  config = mkIf cfg.enable {
    home.packages = devops_pkgs;
    bundles.dev_envs.provides = derivations_bins devops_pkgs;
  };
}
