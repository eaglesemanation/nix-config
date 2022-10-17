{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.programs.neovide;
in {
  options = {
    programs.neovide = {
      enable = mkEnableOption "Neovide";
      package = mkPackageOption pkgs "neovide" {};
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
