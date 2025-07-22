{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
lib.mkIf (builtins.elem "rust" config.emnt.lang_support.langs) {
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];

  home.packages = builtins.attrValues {
    inherit (pkgs) cargo-nextest cargo-cross cargo-edit;
    inherit (pkgs.rust-bin.nightly.latest) default rust-analyzer;
  };
}
