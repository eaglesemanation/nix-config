{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkMerge
    mkIf
    ;
  cfg = config.emnt.dev_env.cpp;
in
{
  options.emnt.dev_env.cpp = {
    enable = mkEnableOption "C/C++ development environment";
    embedded = mkOption {
      default = true;
      description = "Wheter to enable additional tools for embedded Rust development.";
      example = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      (builtins.attrValues { inherit (pkgs) clang-tools cmake-language-server; })
    ];
  };
}
