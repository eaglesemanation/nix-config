{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.emnt-lib) derivations_bins;
  cfg = config.bundles.dev_env.lua;

  lua_pkgs =
    builtins.attrValues { inherit (pkgs) stylua sumneko-lua-language-server; };

in {
  options.bundles.dev_env.lua.enable =
    mkEnableOption "Lua development environment";

  config = mkIf cfg.enable {
    home.packages = lua_pkgs;
    bundles.dev_envs.provides = derivations_bins lua_pkgs;
  };
}
