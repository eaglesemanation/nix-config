{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.typescript;
in {
  options.bundles.dev_env.typescript.enable =
    mkEnableOption "TypeScript development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues { inherit (pkgs) deno; };
  };
}
