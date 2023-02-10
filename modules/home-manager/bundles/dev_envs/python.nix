{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.python;
in {
  options.bundles.dev_env.python.enable =
    mkEnableOption "Python development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) python3 pipx poetry;
      inherit (pkgs.python3Packages) pip python-lsp-server;
    };
  };
}
