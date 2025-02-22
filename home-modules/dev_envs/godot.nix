{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.dev_env.godot;
in
{
  options.emnt.dev_env.godot.enable = mkEnableOption "Godot game engine environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues { inherit (pkgs) gdtoolkit_4; };
  };
}
