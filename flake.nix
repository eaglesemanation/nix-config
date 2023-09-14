{
  description = "eaglesemanation's Nix configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add home-manager support for cachix binary cache
    declarative-cachix.url = "github:jonascarpay/declarative-cachix";

    # Automatic linting and formatting on commit
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-utils.follows = "utils";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };

    # sops (secrets operations) integration with nix
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };

    # Common libs for nix flakes
    utils.url = "github:numtide/flake-utils";

    # Wrapper for host system OpenGL
    nixgl = {
      url = "github:guibou/nixGL";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };

    # Custom rust toolchains
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    utils,
    pre-commit-hooks,
    ...
  } @ inputs: let
    inherit (self) outputs;
    supportedSystems = builtins.attrValues {
      inherit (utils.lib.system) x86_64-linux aarch64-linux;
    };
  in rec {
    overlays = import ./overlay;

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    checks = utils.lib.eachSystemMap supportedSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          statix.enable = true;
          stylua.enable = true;
          conventional-commits = {
            enable = true;
            name = "Conventional commit messages";
            stages = ["commit-msg"];
            entry = let
              binPath = "${
                packages.${system}.conventional-pre-commit-colorless
              }/bin/conventional-pre-commit";
              commitTypes = nixpkgs.lib.concatStringsSep " " [
                "build"
                "chore"
                "ci"
                "docs"
                "feat"
                "fix"
                "perf"
                "refactor"
                "revert"
                "style"
                "test"
              ];
            in "${binPath} ${commitTypes} .git/COMMIT_MSG";
          };
        };
      };
    });

    # Dev shell with pre-commit hooks automatically configured
    devShells = utils.lib.eachSystemMap supportedSystems (system: {
      default = legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    });

    # Additional derivations
    packages =
      utils.lib.eachSystemMap supportedSystems
      (system: import ./pkgs {pkgs = legacyPackages.${system};});

    # Helper functions
    lib = import ./lib {inherit (nixpkgs) lib;};

    # This instantiates nixpkgs for each system listed above
    legacyPackages = utils.lib.eachSystemMap supportedSystems (system:
      import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues {
          inherit (outputs.overlays) additions modifications;
          nixgl = inputs.nixgl.overlay;
          rust-overlay = inputs.rust-overlay.overlays.default;
        };
        config.allowUnfree = true;
      });

    nixosConfigurations = {
      ## FIXME replace with your hostname
      #your-hostname = nixpkgs.lib.nixosSystem {
      #  pkgs = legacyPackages.x86_64-linux;
      #  specialArgs = { inherit inputs; }; # Pass flake inputs to our config
      #  modules = (builtins.attrValues nixosModules) ++ [
      #    # > Our main nixos configuration file <
      #    ./nixos/configuration.nix
      #  ];
      #};
    };

    homeConfigurations = {
      "eaglesemanation@emnt-x280" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [(./home-manager + "/eaglesemanation@emnt-x280.nix")];
      };
      "eaglesemanation@emnt-desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [(./home-manager + "/eaglesemanation@emnt-desktop.nix")];
      };
    };
  };
}
