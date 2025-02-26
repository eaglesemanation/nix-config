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
    mkIf
    ;
  cfg = config.emnt.nvim;

  aliases = {
    vi = "nvim";
    vim = "nvim";
    vimdiff = "nvim -d";
  };
in
{
  options = {
    emnt.nvim.enable = mkEnableOption "Neovim setup";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (inputs.nixvim.legacyPackages."${pkgs.stdenv.hostPlatform.system}".makeNixvimWithModule {
        module = ../nixvim;
        extraSpecialArgs = {
          inherit flake;
          hmConfig = config;
        };
      })
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs = {
      bash.shellAliases = aliases;
      fish.shellAliases = aliases;
      zsh.shellAliases = aliases;
    };
  };
}
