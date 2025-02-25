{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkEnableOption
    mkIf
    ;
  cfg = config.emnt.nvim;
in
{
  options = {
    emnt.nvim = {
      enable = mkEnableOption "Neovim setup";
      setAsEditor = mkOption {
        type = types.bool;
        default = true;
        description = ''Sets EDITOR="nvim"'';
      };
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      imports = [ (import ../nixvim { inherit flake; }) ];
    };
  };
}
