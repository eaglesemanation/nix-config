{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.rust;
in {
  options.bundles.dev_env.rust.enable =
    mkEnableOption "Rust development environment";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
    ] ++ builtins.attrValues {
      inherit (pkgs) rust-analyzer-nightly cargo-nextest;
    };
  };
}
