{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf mkMerge;
  inherit (pkgs) stdenv;
  cfg = config.bundles.dev_env.rust;
  tomlFormat = pkgs.formats.toml { };
in {
  options.bundles.dev_env.rust = {
    enable = mkEnableOption "Rust development environment";
    embedded = mkOption {
      default = true;
      description =
        "Wheter to enable additional tools for embedded Rust development.";
      example = false;
    };
    web = mkOption {
      default = true;
      description =
        "Wheter to enable additional tools for web Rust development.";
      example = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      [
        (pkgs.rust-bin.selectLatestNightlyWith (toolchain:
          toolchain.default.override {
            extensions = [ "miri" "rust-src" "rust-analyzer" ];
            targets =
              [ "wasm32-unknown-unknown" "riscv32imac-unknown-none-elf" ];
          }))
      ]
      (builtins.attrValues {
        inherit (pkgs)
          cargo-generate cargo-nextest cargo-expand cargo-bloat mold;
        inherit (pkgs.vscode-extensions.vadimcn) vscode-lldb;
      })
      (mkIf cfg.embedded (builtins.attrValues { inherit (pkgs) probe-rs; }))
      (mkIf cfg.web
        (builtins.attrValues { inherit (pkgs) trunk cargo-leptos; }))
    ];

    home.file.".cargo/config.toml" = mkIf stdenv.isLinux {
      source = tomlFormat.generate "cargo-config" {
        target.${stdenv.targetPlatform.config} = {
          linker = "clang";
          rustflags = [ "-C" "link-arg=--ld-path=${pkgs.mold}/bin/mold" ];
        };
      };
    };
  };
}
