{ lib, pkgs, inputs, outputs, ... }: {
  imports = [
    # Hacks specific for host OS
    ./host_os
    # Cachix integration with home-manager
    inputs.declarative-cachix.homeManagerModules.declarative-cachix-experimental
    # Provides "bundles"
    outputs.homeManagerModules
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Includes nix path for desktop entries search
  xdg.enable = true;

  # Regenerates list of fonts
  fonts.fontconfig.enable = true;

  programs = {
    # Bootstrap
    home-manager.enable = true;
    # Automatically load programs in devShell for each project
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  bundles.nvim.gitUrl = {
    fetch = "https://github.com/eaglesemanation/nvim-config.git";
    push = "git@github.com:eaglesemanation/nvim-config.git";
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
    sha256 = "0m6kb0a0m3pr6bbzqz54x37h5ri121sraj1idfmsrr6prknc7q3x";
  }];

  home.packages = builtins.attrValues { inherit (pkgs) cachix; };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = lib.mkDefault "22.05";
}
