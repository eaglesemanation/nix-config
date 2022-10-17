# Nix-config

Personal set of Nix, NixOS and home-manager configurations, for declarative management of devices

## Usage

- Applying NixOS config: `sudo nixos-rebuild switch --flake .#hostname`
  - For bootstraping from Live image: `nixos-install --flake github.com/eaglesemanation/nix-config#hostname`
- Applying home-manager config: `home-manager switch --flake .#username@hostname`
  - For bootstraping home-manager: `nix shell nixpkgs#home-manager`

## Credits

This repo is created from [Misterio77 template](https://github.com/Misterio77/nix-starter-configs)
