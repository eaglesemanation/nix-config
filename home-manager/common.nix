{ lib, pkgs, outputs, ... }:
{
  # Include modules that are being exported on flake level + all bundles that can be configured per host
  imports = [ ./bundles ./host_os ] ++ builtins.attrValues outputs.homeManagerModules;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Includes nix path for desktop entries search
  xdg.enable = true;

  programs = {
    home-manager.enable = true;
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      # Disable annoying warning about flake git repo being dirty
      warn-dirty = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = lib.mkDefault "22.05";
}
