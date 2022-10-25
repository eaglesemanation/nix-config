{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.typescript;

  typescript_pkgs = builtins.attrValues { inherit (pkgs) deno; };
in {
  options.bundles.dev_env.typescript.enable =
    mkEnableOption "TypeScript development environment";

  config = mkIf cfg.enable {
    home.packages = typescript_pkgs;
    bundles.dev_envs.provides = derivations_bins typescript_pkgs;
  };
}
