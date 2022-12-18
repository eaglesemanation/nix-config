{ lib, pkgs, inputs, outputs, ... }: {
  imports = [
    # Software that is grouped by usage, for ease of configuring different systems with just a few flags
    ./bundles
    # Hacks specific for host OS
    ./host_os
    # Cachix integration with home-manager
    inputs.declarative-cachix.homeManagerModules.declarative-cachix
  ] ++ builtins.attrValues outputs.homeManagerModules;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Includes nix path for desktop entries search
  xdg.enable = true;

  programs = {
    # Bootstrap
    home-manager.enable = true;
    # Automatically load programs in devShell for each project
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Disable annoying warning about flake git repo being dirty
      warn-dirty = false;
    };
    registry = {
      # Stops nix from periodically fetching newest index, use the one that's already locked instead
      nixpkgs.flake = inputs.nixpkgs;
    };
  };

  # Use public binary cache
  caches.cachix = [{
    name = "nix-community";
    sha256 = "1rgbl9hzmpi5x2xx9777sf6jamz5b9qg72hkdn1vnhyqcy008xwg";
  }];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = lib.mkDefault "22.05";
}
