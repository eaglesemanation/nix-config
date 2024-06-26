{ inputs, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkIf mkMerge types;
  cfg = config.host_os.fedora;
in {
  options = {
    host_os.fedora = {
      enable = mkEnableOption "Fedora compatability";
      opengl = {
        enable = mkOption {
          type = types.bool;
          description = "Enables usage of host OpenGL libraries";
          default = cfg.enable;
        };
        kind = mkOption {
          type = types.addCheck (types.nullOr (types.enum [ "mesa" "nvidia" ]))
            (val: cfg.opengl.enable && val != null);
          description =
            "Configures which OpenGL implementation to use, 'nvidia' is self explanatory, 'mesa' for Intel and AMD";
          default = null;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Enables zsh completions and probably other stuff
      targets.genericLinux.enable = true;

      # Fixes issues in communication between GnuPG and YubiKey
      programs.gpg.scdaemonSettings.pcsc-driver =
        "/usr/lib64/libpcsclite.so.1.0.0";
    }
    # Wrap apps requiring OpenGL
    (mkIf cfg.opengl.enable (let
      nixGLPrefix = if cfg.opengl.kind == "mesa" then
        "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel"
      else if cfg.opengl.kind == "nvidia" then
        "${pkgs.nixgl.nixGLNvidia}/bin/nixGLNvidia"
      else
        throw ''

          Unexpected kind for OpenGL overwrite: ${cfg.opengl.manufacturer}'';

      nixGLWrap = { name, pkg, }:
        pkgs.symlinkJoin {
          inherit name;
          paths = [
            (pkgs.writeShellScriptBin name ''
              exec ${nixGLPrefix} ${pkg}/bin/${name} "$@"
            '')
            pkg
          ];
        };
    in {
      programs.wezterm.package = nixGLWrap {
        name = "wezterm";
        pkg = pkgs.wezterm;
      };
    }))
  ]);
}
