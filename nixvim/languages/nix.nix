{
  flake,
  lib,
  pkgs,
  config,
  ...
}@inputs:
lib.mkIf (builtins.elem "nix" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers.nixd = {
      enable = true;
      settings = let
        getFlake = ''(builtins.getFlake "${flake}")'';
      in {
        offset_encoding = "utf-8";
        formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
        nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
        options =
          {
            nixvim.expr = "${getFlake}.packages.${pkgs.system}.nvim.options";
          }
          // (
            if (builtins.hasAttr "hmConfig" inputs) then
              { home-manager.expr = "${getFlake}.homeConfigurations.${inputs.hmConfig.home.username}.options"; }
            else
              { }
          );
      };
    };
  };
}
