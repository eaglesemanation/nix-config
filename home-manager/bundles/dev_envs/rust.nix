{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.rust;

  rust_pkgs = builtins.attrValues {
    inherit (pkgs.fenix.complete)
      cargo clippy rust-src rustc rustfmt rust-analyzer;
  };

in {
  options.bundles.dev_env.rust.enable =
    mkEnableOption "Rust development environment";

  config = mkIf cfg.enable {
    home.packages = rust_pkgs;
    bundles.dev_envs.provides = derivations_bins rust_pkgs;
  };
}
