{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption types mkEnableOption mkIf;
  cfg = config.bundles.nvim;
in {
  options = {
    bundles.nvim = {
      enable = mkEnableOption "Neovim bundle";
      gitUrl = {
        fetch = mkOption {
          type = types.nonEmptyStr;
          description = "Git repo URL with Neovim config";
        };
        push = mkOption {
          type = types.nonEmptyStr;
          default = cfg.gitUrl.fetch;
          description = "Git repo URL for pushing config updates";
        };
      };
      setAsEditor = mkOption {
        type = types.bool;
        default = true;
        description = ''Sets EDITOR="nvim"'';
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
      # LSP to linters/formatters compatability
      efm-langserver
    ];

    home.sessionVariables = mkIf cfg.setAsEditor { EDITOR = "nvim"; };

    # Pulls Neovim config from git repo and keeps it decoupled from nix conf
    home.activation.nvimConfGit = ''
      if [ -v DRY_RUN ]; then
        # TODO: Actually log which commands would be executed
        echo "Dry run, skipping"
        exit 0
      fi

      if [ ! -v XDG_CONFIG_HOME ] || [ -z "$XDG_CONFIG_HOME" ]; then
        export XDG_CONFIG_HOME="$HOME/.config"
      fi
      CONF_PATH="$XDG_CONFIG_HOME/nvim"
      if [ ! -d "$CONF_PATH" ]; then
        git clone ${cfg.gitUrl.fetch} "$CONF_PATH"
      fi

      pushd "$CONF_PATH" >/dev/null 2>&1

      set +e
      git rev-parse --is-inside-work-tree >/dev/null 2>&1
      IS_GIT=$?
      set -e

      if [ $IS_GIT -eq 0 ] || [ -v DRY_RUN ]; then
        git remote set-url origin ${cfg.gitUrl.fetch}
        git remote set-url origin --push ${cfg.gitUrl.push}
      else
        echo "Neovim config dir already exists and it's not a git repo"
        echo "Clean it up and try again"
        exit 1
      fi
      popd >/dev/null 2>&1
    '';

    home.file.ignore = {
      source = ./.ignore;
      target = ".ignore";
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      vimdiffAlias = true;
    };
  };
}
