{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.dev_env.lua;
in
{
  options.emnt.dev_env.lua.enable = mkEnableOption "Lua development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) stylua sumneko-lua-language-server;
    };
  };
}
