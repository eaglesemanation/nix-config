{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf subtractLists;
  cfg = config.emnt.lang_support;
  langIncluded = builtins.elem "nix" (subtractLists cfg.blacklist cfg.langs);
in
{
  config = mkIf langIncluded {
    plugins = {
      lsp.servers.nixd = {
        enable = true;
        settings = {
          formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
          options =
            let
              getFlake = ''(builtins.getFlake "${flake}")'';
            in
            {
              home-manager.expr = ''${getFlake}.homeConfigurations."eaglesemanation".options'';
              hixvim.expr = ''${getFlake}.packages.${pkgs.system}.nvim.options'';
            };
        };
      };
    };
  };
}
