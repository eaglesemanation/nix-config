{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.terminal;
in
{
  options = {
    bundles.terminal = {
      enable = mkEnableOption "Terminal bundle";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nerd-fonts.recursive-mono ];

    programs.wezterm = {
      enable = true;
      extraConfig = builtins.replaceStrings [ "/usr/bin/zsh" ] [ "${lib.getExe pkgs.zsh}" ] (
        lib.strings.fileContents ./wezconfig.lua
      );
    };

    # Shell
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      dotDir = ".config/zsh";
      history.path = "${config.xdg.dataHome}/zsh/zsh_history";
      initExtra = ''
        # Set window title to current path
        precmd() {
          echo -ne "\033]0;$(print -P '%(4~|%-1~/…/%2~|%3~)')\007"
        }

        # [f]ind [p]roject
        function fp() {
            proj_path=$(cat "''${XDG_DATA_HOME:-$HOME/.local/share}/nvim/telescope-projects.txt" \
                | awk -F '=' '$4 == 1 {print $2 "=" $1}' \
                | sk --delimiter '=' --with-nth 2 --query "$1" --select-1 \
                | awk -F '=' '{print $1}')
            cd "$proj_path"
        }
      '';
    };
  };
}
