{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption types mkEnableOption mkIf;
  inherit (pkgs) fetchFromGitHub;
  cfg = config.bundles.terminal;

  # Script for terminal emulator initialization.
  # Currently takes name of terminal as an argument, and
  # creates a new tmux session, which is killed on exit
  terminal_init = pkgs.writeShellScriptBin "init.sh" ''
    prefix=""
    if [ -n "$1" ]; then
      prefix="$1-"
    fi
    _trap_exit() {
      ${pkgs.tmux}/bin/tmux kill-session -t "$prefix$$";
    }
    trap _trap_exit EXIT
    ${pkgs.tmux}/bin/tmux new-session -s "$prefix$$"
  '';

  alacritty-themes = fetchFromGitHub {
    owner = "eendroroy";
    repo = "alacritty-theme";
    rev = "1e0dbc5530ce1297cacfb17dcae1366ecf581af6";
    sha256 = "iSJOmMd8rDTJc7B+X6WQ5hCs281NS+igPycW3rN4ifc=";
  };
in {
  options = {
    bundles.terminal = {
      enable = mkEnableOption "Terminal bundle";
      font = mkOption {
        type = types.str;
        default = "Monoid";
        description = "Name of a font from Nerdfonts";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [ (nerdfonts.override { fonts = [ cfg.font ]; }) ];

    # Terminal emulator
    programs.alacritty = let font = "${cfg.font} Nerd Font";
    in {
      enable = true;
      settings = {
        shell = {
          program = "${terminal_init}/bin/init.sh";
          args = [ "alacritty" ];
        };
        import = [ "${alacritty-themes}/themes/solarized_dark.yaml" ];
        font = {
          normal = {
            family = font;
            style = "Retina";
          };
          bold = {
            family = font;
            style = "Bold";
          };
          italic = {
            family = font;
            style = "Italic";
          };
          bold_italic = {
            family = font;
            style = "Bold Italic";
          };
          size = 11;
        };
      };
    };

    # Terminal multiplexer
    programs.tmux = {
      enable = true;
      # Count from 1, for easier shortcuts
      baseIndex = 1;
      # Use 24-hour clock
      clock24 = true;
      # Enable full color support
      terminal = "tmux-256color";
      prefix = "C-a";
      shell = "${pkgs.zsh}/bin/zsh";
      extraConfig = ''
        # Removes delay when pressing Esc in Nvim, not sure of actual meaning
        set -s escape-time 0
        # Moves window list to the center
        set -g status-justify absolute-centre
        # Allows for longer session names
        set -g status-left-length 25
        # Force full color support in tmux for alacritty
        set-option -sa terminal-overrides ',alacritty:RGB,xterm-256color:RGB'
        # Enable scrollback with mouse
        set -g mouse on
        # Increase limit of lines for scrollback
        set -g history-limit 50000
        # Include title into tab name
        set-window-option -g window-status-current-format "#I:#W '#T'"
        set-window-option -g window-status-format "#I:#W '#T'"
        # Highlight selected tab
        set-window-option -g window-status-current-style bg=blue
      '';
      plugins =
        lib.attrValues { inherit (pkgs.tmuxPlugins) pain-control logging; };
    };

    # Shell
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      dotDir = ".config/zsh";
      history.path = "${config.xdg.dataHome}/zsh/zsh_history";
      profileExtra = ''
        function nixpkgs_search() {
          found="$(nix search --json nixpkgs "$1" | jq -r 'keys | .[]' | sk)"
          if [ -n "$found" ]; then
            nix search "nixpkgs#$found"
          fi
        }
      '';
      initExtra = ''
        precmd() {
          echo -ne "\033]0;$(print -P '%(4~|%-1~/…/%2~|%3~)')\007"
        }
      '';
    };
  };
}
