{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.terminal;

  zellijWrapper = pkgs.writeShellScript "zellij-nix-wrapper" ''
    if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
    if [ -e ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    fi
    exec ${lib.getExe pkgs.zellij} "$@"
  '';

  zellijPlugins = {
    vim-zellij-navigator = builtins.fetchurl {
      url = "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm";
      sha256 = "sha256:13f54hf77bwcqhsbmkvpv07pwn3mblyljx15my66j6kw5zva5rbp";
    };
  };
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
    };
    xdg.configFile."wezterm/wezterm.lua".source = pkgs.replaceVars ./wezterm.lua {
      zellij = if config.targets.genericLinux.enable then zellijWrapper else (lib.getExe pkgs.zellij);
    };

    programs.zellij.enable = true;
    xdg.configFile."zellij/config.kdl".source = pkgs.replaceVars ./zellij.kdl {
      inherit (zellijPlugins) vim-zellij-navigator;
      fish = lib.getExe pkgs.fish;
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
