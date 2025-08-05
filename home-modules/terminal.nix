{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.terminal;

  # Using this until post_command_discovery_hook becomes available
  zellijUnstable = pkgs.zellij.overrideAttrs (oldAttrs: rec {
    version = "0.43.0";
    src = oldAttrs.src.override {
      tag = null;
      rev = "b634a57de8f0025de36dd19e3e7916d2b27e38cd";
      hash = "sha256-a0JJD+9neYOyDx/gAxPIdthTg695ShU93palExu3Vvo=";
    };
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-P4VabkEFBvj2YkkhXqH/JZp3m3WMKcr0qUMhdorEm1Q=";
    };
  });

  zellijWrapper = pkgs.writeShellScript "zellij-nix-wrapper" ''
    if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
    if [ -e ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    fi
    exec ${lib.getExe zellijUnstable} "$@"
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
        background = "#272e33";
        foreground = "#d3c6aa";
      };
      normal = {
        black = "#414b50";
        red = "#e67e80";
        green = "#a7c080";
        yellow = "#dbbc7f";
        blue = "#7fbbb3";
        magenta = "#d699b6";
        cyan = "#83c092";
        white = "#d3c6aa";
      };
      bright = {
        black = "#475258";
        red = "#e67e80";
        green = "#a7c080";
        yellow = "#dbbc7f";
        blue = "#7fbbb3";
        magenta = "#d699b6";
        cyan = "#83c092";
        white = "#d3c6aa";
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

    programs.zellij = {
      enable = true;
      package = zellijUnstable;
    };
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
          set session_path $(ls "$session_dir" | sed 's/%2F/\//g; s/%2E/./g; s/.vim$//' | sk --query "$1" --select-1)
          cd "$session_path"
        '';
      };
    };
  };
}
