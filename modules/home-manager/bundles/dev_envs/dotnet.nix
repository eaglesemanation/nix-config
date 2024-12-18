{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.dotnet;
in
{
  options.bundles.dev_env.dotnet.enable = mkEnableOption "C# development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues { inherit (pkgs) dotnet-sdk omnisharp-roslyn; };
  };
}
