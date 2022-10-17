{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.nvim;
in {
  options = {
    bundles.nvim.enable = mkEnableOption "Neovim bundle";
  };

  config = mkIf cfg.enable{
    home.packages = with pkgs; [
      # nvim-treesitter will fail if non Nix gcc is used
      gcc
      # telescope external dependencies
      ripgrep fd
      # language servers
      clang-tools deno stylua shellcheck terraform yaml-language-server cmake-language-server
    ];

    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      vimdiffAlias = true;
    };

    programs.neovide.enable = true;
  };
}
