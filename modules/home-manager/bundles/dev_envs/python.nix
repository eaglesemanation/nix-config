{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.python;
in
{
  options.bundles.dev_env.python.enable = mkEnableOption "Python development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) uv ruff;
      inherit (pkgs.python3Packages) python-lsp-server;
    };
  };
}
