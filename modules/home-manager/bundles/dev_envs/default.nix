{ lib, pkgs, config, ... }:
let
  inherit (lib)
    mkOption mkEnableOption mkIf types attrNames filterAttrs removeSuffix
    hasSuffix;
  cfg = config.bundles.dev_envs;

  envFilenames = attrNames (filterAttrs
    (n: v: v == "regular" && n != "default.nix" && (hasSuffix ".nix" n))
    (builtins.readDir ./.));
  envs = builtins.map (removeSuffix ".nix") envFilenames;
in {
  options.bundles.dev_envs = {
    enable = mkEnableOption "Tools for software development";
    enableEnvironments = mkOption {
      type = types.listOf (types.enum envs);
      description = "List of development environments that need to be enabled";
      default = envs;
    };
    disableEnvironments = mkOption {
      type = types.listOf (types.enum envs);
      description =
        "List of development environments that need to be disabled (as blacklist)";
      default = [ ];
    };
  };

  imports = builtins.map (n: ./. + "/${n}") envFilenames;

  config = mkIf cfg.enable {
    bundles.dev_env = let
      filteredEnvs =
        builtins.filter (e: !(builtins.elem e cfg.disableEnvironments))
        cfg.enableEnvironments;
    in lib.genAttrs filteredEnvs (_: { enable = true; });
  };
}
