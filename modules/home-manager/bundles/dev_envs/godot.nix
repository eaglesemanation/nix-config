{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.godot;
in
{
  options.bundles.dev_env.godot.enable = mkEnableOption "Godot game engine environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues { inherit (pkgs) gdtoolkit_4; };
  };
}
