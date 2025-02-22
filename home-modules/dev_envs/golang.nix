{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.dev_env.golang;
in
{
  options.emnt.dev_env.golang.enable = mkEnableOption "Go lang development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        go
        golangci-lint
        gopls
        delve
        ;
    };
  };
}
