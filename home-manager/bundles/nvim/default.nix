{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption types mkEnableOption mkIf;
  cfg = config.bundles.nvim;
in
{
  options = {
    bundles.nvim = {
      enable = mkEnableOption "Neovim bundle";
      setAsEditor = mkOption {
        type = types.bool;
        default = true;
        description = "Sets EDITOR=\"nvim\"";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # nvim-treesitter will fail if non Nix gcc is used
      gcc
      tree-sitter
      # telescope external dependencies
      ripgrep
      fd
      # language servers
      clang-tools
      deno
      stylua
      shellcheck
      terraform
      yaml-language-server
      cmake-language-server
    ];

    home.sessionVariables = mkIf cfg.setAsEditor {
      EDITOR = "nvim";
    };

    xdg.configFile.nvim = {
      recursive = true;
      source = ./nvimrc;
      target = "nvim";
      onChange = ''
         nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
      '';
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      vimdiffAlias = true;
    };

    programs.neovide.enable = true;
  };
}
