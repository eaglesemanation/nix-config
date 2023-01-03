{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.java;
in {
  options.bundles.dev_env.java.enable =
    mkEnableOption "Java development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) openjdk gradle jdt-language-server;
    };
  };
}
