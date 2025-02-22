{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.dev_env.typescript;
in
{
  options.emnt.dev_env.typescript.enable = mkEnableOption "TypeScript development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        nodejs
        typescript
        prettierd
        eslint_d
        ;
      inherit (pkgs.nodePackages)
        yarn
        pnpm
        sass
        typescript-language-server
        stylelint
        vscode-langservers-extracted
        ;
    };
  };
}
