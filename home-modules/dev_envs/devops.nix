{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.dev_env.devops;
in
{
  options.emnt.dev_env.devops.enable = mkEnableOption "DevOps environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        shellcheck
        yaml-language-server
        yamlfmt
        jsonnet-language-server
        taplo
        ;
      inherit (pkgs.nodePackages) vscode-langservers-extracted;
    };
  };
}
