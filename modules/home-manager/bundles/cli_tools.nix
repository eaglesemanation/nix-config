{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption types mkEnableOption mkIf;
  cfg = config.bundles.cli_tools;
in {
  options.bundles.cli_tools.enable = mkEnableOption "CLI tools bundle";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jq # Parsing JSON in terminal
      tealdeer # tldr, short version of man pages
      xh # httpie analog written in Rust, simple CLI for HTTP requests
    ];

    programs.zsh.shellAliases = { http = "xh"; };

    # Shell prompt
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        username.show_always = true;
        character = {
          success_symbol = "[ﬦ](bold green)";
          error_symbol = "[ﬦ](bold red)";
          vimcmd_symbol = "[](bold green)";
          vimcmd_replace_one_symbol = "[](bold purple)";
          vimcmd_replace_symbol = "[](bold purple)";
          vimcmd_visual_symbol = "[](bold yellow)";
        };
        aws.symbol = " ";
        c.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = "ﳑ ";
        nix_shell.symbol = " ";
      };
    };

    # Starship changes prompt when entering nix shell, no need for env diff log. This makes direnv silent
    # TODO: Find / implement a fix that makes direnv less verbose rather than silent
    home.sessionVariables =
      mkIf config.programs.starship.enable { DIRENV_LOG_FORMAT = ""; };

    # Fuzzy search, integrates with zsh
    programs.skim.enable = true;

    programs.git = {
      enable = true;
      lfs.enable = true;
    };
  };
}
