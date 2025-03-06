{
  flake,
  lib,
  pkgs,
  config,
  hmConfig ? null,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (import ../lib.nix { inherit lib; }) mkIfLang;
  getFlake = ''(builtins.getFlake "${flake}")'';
in
{
  config = mkIfLang config.emnt.lang_support "nix" {
    plugins = {
      lsp.servers.nixd = {
        enable = true;
        settings = {
          offset_encoding = "utf-8";
          formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
          nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
          options = {
            home-manager.expr = mkIf (
              hmConfig != null
            ) "${getFlake}.homeConfigurations.${hmConfig.home.username}.options";
            hixvim.expr = "${getFlake}.packages.${pkgs.system}.nvim.options";
          };
        };
      };
    };
  };
}
