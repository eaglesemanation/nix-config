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

  alacrittyThemes = {
    everforest_dark_hard = {
      primary = {
        background = "#272E33";
        foreground = "#D3C6AA";
      };
      normal = {
        black = "#2E383C";
        red = "#E67E80";
        green = "#A7C080";
        yellow = "#DBBC7F";
        blue = "#7FBBB3";
        magenta = "#D699B6";
        cyan = "#83C092";
        white = "#D3C6AA";
      };
      bright = {
        black = "#5C6A72";
        red = "#F85552";
        green = "#8DA101";
        yellow = "#DFA000";
        blue = "#3A94C5";
        magenta = "#DF69BA";
        cyan = "#35A77C";
        white = "#DFDDC8";
      };
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

    programs.alacritty = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.alacritty;
      settings = {
        colors = alacrittyThemes.everforest_dark_hard;
        terminal.shell = {
          program = zellijWrapper;
          args = [
            "-l"
            "welcome"
          ];
        };
        font = {
          normal.family = "Iosevka Nerd Font";
          size = 14;
        };
      };
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
        fs = ''
          set data_home "$XDG_DATA_HOME"
          test -z "$data_home"; and set data_home "$HOME/.local/share"
          set session_dir "$data_home/nvim/sessions/"
          set session_path $(ls "$session_dir" | sed 's/%2F/\//g; s/%2E/./g; s/.vim$//' | sk --query "$argv[1]" --select-1)
          test -n "$session_path"; and cd "$session_path"
        '';
      };
    };
  };
}
