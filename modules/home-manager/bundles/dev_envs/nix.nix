{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.nix;
in {
  options.bundles.dev_env.nix.enable =
    mkEnableOption "Nix development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues { inherit (pkgs) nixfmt nil; };
  };
}
