{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.rust;
in {
  options.bundles.dev_env.rust.enable =
    mkEnableOption "Rust development environment";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.rust-bin.selectLatestNightlyWith (toolchain:
        toolchain.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        }))
    ];
  };
}
