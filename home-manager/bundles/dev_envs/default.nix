{ lib, pkgs, config, ... }:
let
  inherit (lib)
    mkOption mkEnableOption mkIf types attrNames filterAttrs removeSuffix;
  cfg = config.bundles.dev_envs;

  env_filenames = attrNames
    (filterAttrs (n: v: v == "regular" && n != "default.nix")
      (builtins.readDir ./.));
  envs = builtins.map (v: removeSuffix ".nix" v) env_filenames;
in {
  options.bundles.dev_envs = {
    enable = mkEnableOption "Tools for software development";
    environments = mkOption {
      type = types.listOf (types.enum envs);
      description = "List of development environments that need to be enabled";
      default = envs;
    };
  };

  imports = builtins.map (n: ./. + "/${n}") env_filenames;

  config = mkIf cfg.enable {
    bundles.dev_env = lib.genAttrs cfg.environments (_: { enable = true; });
  };
}
