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
      extraConfig = builtins.replaceStrings [ "/usr/bin/zellij" ] [ "${lib.getExe pkgs.zellij}" ] (
        lib.strings.fileContents ./wezconfig.lua
      );
    };

    programs.zellij = {
      enable = true;
      settings = {
        theme = "everforest-dark";
        default_shell = "${lib.getExe pkgs.fish}";
        show_startup_tips = false;
      };
    };

    home.shell.enableFishIntegration = true;
    programs.fish = {
      enable = true;
      functions = {
        fish_command_not_found = "echo Did not find command $argv[1]";
        fp = ''
          set data_home "$XDG_DATA_HOME"
          test -z "$data_home"; and set data_home "$HOME/.local/share"
          set proj_file "$data_home/nvim/project_nvim/project_history"
          set proj_path $(cat "$proj_file" | sk --query "$1" --select-1)
          cd "$proj_path"
        '';
      };
    };
  };
}
