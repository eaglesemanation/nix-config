{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.rust;
in {
  options.bundles.dev_env.rust.enable = mkEnableOption "Rust development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs.fenix.complete) cargo clippy rust-src rustc rustfmt rust-analyzer;
    };
  };
}
