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
    provides_file = {
      enable = mkOption {
        type = types.bool;
        description =
          "Enable dumping list of executable names into a JSON file for consumtion by other programs";
        default = true;
      };
      path = mkOption {
        type = types.str;
        description =
          "Path to a JSON file with executable names, relative to ${config.xdg.dataHome}";
        default = "nix/dev_envs_provides.json";
      };
    };
    provides = mkOption {
      type = types.listOf (types.str);
      default = [ ];
    };
  };

  imports = builtins.map (n: ./. + "/${n}") env_filenames;

  config = mkIf cfg.enable {
    bundles.dev_env = lib.genAttrs cfg.environments (_: { enable = true; });

    xdg.dataFile.dev_envs_provides = {
      text = builtins.toJSON cfg.provides;
      target = cfg.provides_file.path;
    };
  };
}
