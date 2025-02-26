{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (import ../lib.nix { inherit lib; }) mkIfLang;
in
{
  config = mkIfLang config.emnt.lang_support "nix" {
    plugins = {
      lsp.servers.nixd = {
        enable = true;
        settings = {
          offset_encoding = "utf-8";
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
