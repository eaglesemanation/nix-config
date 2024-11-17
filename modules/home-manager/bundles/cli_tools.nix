{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkEnableOption
    mkIf
    ;
  cfg = config.bundles.cli_tools;
in
{
  options.bundles.cli_tools.enable = mkEnableOption "CLI tools bundle";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jq # Parsing JSON in terminal
      yq # Parsing YAML in terminal
      tealdeer # tldr, short version of man pages
      xh # httpie analog written in Rust, simple CLI for HTTP requests
      coreutils # ls, mv, cp etc.
      nh # nix wrapper
    ];

    programs = {
      git = {
        enable = true;
        lfs.enable = true;
        extraConfig = {
          rerere.enabled = true;
          column.ui = "auto";
          init.defaultBranch = "main";
          branch.sort = "-committerdate";
          fetch.writeCommitGraph = true;
          rebase.updateRefs = true;
        };
      };

      zsh = {
        shellAliases = {
          http = "xh";
          https = "xh --https";
          grep = "grep --color=auto";
          ls = "ls --hyperlink=auto --color=auto";
        };
      };

      # Fuzzy search, integrates with zsh
      skim.enable = true;

      # Shell prompt
      starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          username.show_always = true;
          character = {
            success_symbol = "[󰘧](bold green)";
            error_symbol = "[󰘧](bold red)";
            vimcmd_symbol = "[󰏉](bold green)";
            vimcmd_replace_one_symbol = "[󰏉](bold purple)";
            vimcmd_replace_symbol = "[󰏉](bold purple)";
            vimcmd_visual_symbol = "[󰏉](bold yellow)";
          };
          aws.symbol = "  ";
          buf.symbol = " ";
          c.symbol = " ";
          conda.symbol = " ";
          crystal.symbol = " ";
          dart.symbol = " ";
          directory.read_only = " 󰌾";
          docker_context.symbol = " ";
          elixir.symbol = " ";
          elm.symbol = " ";
          fennel.symbol = " ";
          fossil_branch.symbol = " ";
          git_branch.symbol = " ";
          golang.symbol = " ";
          guix_shell.symbol = " ";
          haskell.symbol = " ";
          haxe.symbol = " ";
          hg_branch.symbol = " ";
          hostname.ssh_symbol = " ";
          java.symbol = " ";
          julia.symbol = " ";
          kotlin.symbol = " ";
          lua.symbol = " ";
          memory_usage.symbol = "󰍛 ";
          meson.symbol = "󰔷 ";
          nim.symbol = "󰆥 ";
          nix_shell.symbol = " ";
          nodejs.symbol = " ";
          ocaml.symbol = " ";
          os.symbols = {
            Alpaquita = " ";
            Alpine = " ";
            # AlmaLinux = " ";
            Amazon = " ";
            Android = " ";
            Arch = " ";
            Artix = " ";
            CentOS = " ";
            Debian = " ";
            DragonFly = " ";
            Emscripten = " ";
            EndeavourOS = " ";
            Fedora = " ";
            FreeBSD = " ";
            Garuda = "󰛓 ";
            Gentoo = " ";
            HardenedBSD = "󰞌 ";
            Illumos = "󰈸 ";
            # Kali = " ";
            Linux = " ";
            Mabox = " ";
            Macos = " ";
            Manjaro = " ";
            Mariner = " ";
            MidnightBSD = " ";
            Mint = " ";
            NetBSD = " ";
            NixOS = " ";
            OpenBSD = "󰈺 ";
            openSUSE = " ";
            OracleLinux = "󰌷 ";
            Pop = " ";
            Raspbian = " ";
            Redhat = " ";
            RedHatEnterprise = " ";
            # RockyLinux = " ";
            Redox = "󰀘 ";
            Solus = "󰠳 ";
            SUSE = " ";
            Ubuntu = " ";
            Unknown = " ";
            # Void = " ";
            Windows = "󰍲 ";
          };
          package.symbol = "󰏗 ";
          perl.symbol = " ";
          php.symbol = " ";
          pijul_channel.symbol = " ";
          python.symbol = " ";
          rlang.symbol = "󰟔 ";
          ruby.symbol = " ";
          rust.symbol = " ";
          scala.symbol = " ";
          swift.symbol = " ";
          zig.symbol = " ";
        };
      };
    };

    # Starship changes prompt when entering nix shell, no need for env diff log. This makes direnv silent
    # TODO: Find / implement a fix that makes direnv less verbose rather than silent
    home.sessionVariables = mkIf config.programs.starship.enable { DIRENV_LOG_FORMAT = ""; };
  };
}
