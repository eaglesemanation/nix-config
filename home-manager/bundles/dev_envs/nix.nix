{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.nix;

  nix_pkgs = builtins.attrValues { inherit (pkgs) rnix-lsp nixfmt; };

in {
  options.bundles.dev_env.nix.enable =
    mkEnableOption "Nix development environment";

  config = mkIf cfg.enable {
    home.packages = nix_pkgs;
    bundles.dev_envs.provides = derivations_bins nix_pkgs;
  };
}
