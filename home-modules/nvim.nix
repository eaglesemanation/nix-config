{
  lib,
  config,
  flake,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.emnt.nvim;
in
{
  options = {
    emnt.nvim = {
      enable = mkEnableOption "Install neovim using nixvim module";
      module = mkOption {
        type = types.deferredModule;
        default = flake.nixvimModules.default;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (inputs.nixvim.legacyPackages."${pkgs.stdenv.hostPlatform.system}".makeNixvimWithModule {
        inherit (cfg) module;
        extraSpecialArgs = {
          inherit flake inputs;
          hmConfig = config;
        };
      })
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";
    };
  };
}
