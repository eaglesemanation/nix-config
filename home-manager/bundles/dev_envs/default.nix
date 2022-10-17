{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkIf types attrNames filterAttrs removeSuffix;
  cfg = config.bundles.dev_envs;

  lang_filenames = attrNames (filterAttrs (n: v: v == "regular" && n != "default.nix") (builtins.readDir ./.));
  langs = builtins.map (v: removeSuffix ".nix" v) lang_filenames;
in
{
  options.bundles.dev_envs = {
    enable = mkEnableOption "Tools for software development";
    languages = mkOption {
      type = types.listOf (types.enum langs);
      description = "List of programming languages that need to be enabled";
      default = langs;
    };
  };

  imports = builtins.map (n: ./. + "/${n}") lang_filenames;

  config = mkIf cfg.enable {
    bundles.dev_env = lib.genAttrs cfg.languages (_: { enable = true; });
  };
}
