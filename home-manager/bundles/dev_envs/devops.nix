{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.devops;
in {
  options.bundles.dev_env.devops.enable = mkEnableOption "DevOps environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        shellcheck terraform terraform-ls yaml-language-server kubectl kubectx
        kind;
    };
  };
}
