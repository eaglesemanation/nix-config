{
  description = "eaglesemanation's Nix configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    nixgl.url = "github:nix-community/nixGL";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [
        ez-configs.flakeModule
        nixvim.flakeModules.default
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      ezConfigs = {
        root = ./.;
        globalArgs = {
          inherit inputs;
          flake = self;
        };

        home.users = {
          eaglesemanation = {
            standalone.enable = true;
            standalone.pkgs = import nixpkgs {
              system = "x86_64-linux";
              allowUnfree = true;
            };
          };
        };
      };

      nixvim = {
        packages.enable = true;
        checks.enable = true;
      };

      flake = {
        nixvimModules.default = import ./nixvim;
      };

      perSystem =
        { system, ... }:
        {
          nixvimConfigurations.nvim = inputs.nixvim.lib.evalNixvim {
            inherit system;
            modules = [ self.nixvimModules.default ];
            extraSpecialArgs = {
              inherit inputs;
              flake = self;
            };
          };

          nixvimConfigurations.nvim-minimal = inputs.nixvim.lib.evalNixvim {
            inherit system;
            modules = [
              self.nixvimModules.default
              { emnt.lang_support.enable = [ ]; }
            ];
            extraSpecialArgs = {
              inherit inputs;
              flake = self;
            };
          };
        };
    };
}
