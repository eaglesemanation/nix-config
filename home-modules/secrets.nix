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
  cfg = config.emnt.secrets;

  gpgAgentSshEnv = ''
    SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
  '';
in
{
  options = {
    emnt.secrets = {
      enable = mkEnableOption "Secrets management bundle";
      publicKey = mkOption {
        type = types.path;
        description = "Path to a personal GnuPG public key to import";
      };
      email = mkOption {
        type = types.str;
        description = "Email address used in GnuPG public key for automatic detection. Also will be used for git config";
      };
      name = mkOption {
        type = types.str;
        description = "Username in git config";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sops # Secrets management in YAML with GPG
      age # Modern alternative to PGP
      gcr # GNOME crypto services, to work with pinentry
    ];

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
      enableScDaemon = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };

    programs = {
      bash.initExtra = gpgAgentSshEnv;
      zsh.initContent = gpgAgentSshEnv;
      fish.interactiveShellInit = gpgAgentSshEnv;

      ssh.enable = true;
      git = {
        enable = true;
        userName = cfg.name;
        userEmail = cfg.email;
        signing = {
          key = null; # Decide which key to use automatically
          signByDefault = true;
        };
        extraConfig = {
          pull.rebase = false;
          init.defaultBranch = "main";
        };
      };

      gpg = {
        enable = true;
        publicKeys = [
          {
            source = cfg.publicKey;
            trust = "ultimate";
          }
        ];
        settings = {
          keyserver = "hkps://keys.openpgp.org";
          trust-model = "tofu+pgp";
        };
        scdaemonSettings = {
          disable-ccid = true;
          pcsc-shared = true;
        };
      };
      password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (
          exts: with exts; [
            pass-otp
            pass-update
          ]
        );
        settings = {
          PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass-store";
        };
      };
      browserpass.enable = true;
    };
  };
}
