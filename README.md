# Nix-config

Home-manager, NixOS and NixVim configs combined.

## Using NixVim config

If you have nix setup - the easiest way to try out my setup is to run
```bash
nix run github:eaglesemanation/nix-config#nvim-minimal
```
This will install all plugins, but exclude any software specific to a programming language (with exception of treesitter grammars).
Substitute `nvim-minimal` with `nvim` to try out full setup with all languages enabled.


If you want to make your own config based on mine - you probably shouldn't, I'm not intending to actively maintain this unless I personally have any issues with it. If you still want to - here is bare-minimum flake setup:
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # You might want to point inputs to ones defined above
    # Run `nix flake metadata` for details
    emnt-conf.url = "github:eaglesemanation/nix-config"
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
        nixvim.flakeModules.default
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      # Auto-generate package.${system}.${nixvimConfigrations.name} as an output
      nixvim.packages.enable = true;
      perSystem =
        {system, ...}:
        {
          nixvimConfigurations.nvim = inputs.nixvim.lib.evalNixvim {
            inherit system;
            modules = [ 
              inputs.emnt-conf.nixvimModules.default
              { emnt.lang_support.langs = ["go"]; }
            ];
          };
        }
    };
}
```
This will allow you to run `nix run .#nvim` and have your own version of my setup with just Go support enabled.
