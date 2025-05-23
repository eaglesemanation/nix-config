{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.terminal;
in
{
  options = {
    emnt.terminal = {
      enable = mkEnableOption "Terminal bundle";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nerd-fonts.iosevka ];

    programs.wezterm = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.wezterm;
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
      initContent = ''
        # Set window title to current path
        precmd() {
          echo -ne "\033]0;$(print -P '%(4~|%-1~/…/%2~|%3~)')\007"
        }

        # [f]ind [p]roject
        function fp() {
            proj_path=$(cat "''${XDG_DATA_HOME:-$HOME/.local/share}/nvim/project_nvim/project_history" \
                | sk --query "$1" --select-1)
            cd "$proj_path"
        }
      '';
    };
  };
}
