{ inputs, lib, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./cli_tools.nix
    ./language-support.nix
    ./nvim.nix
    ./secrets.nix
    ./terminal.nix
  ];

  emnt = {
    terminal.enable = lib.mkDefault true;
    nvim.enable = lib.mkDefault true;
    cli_tools.enable = lib.mkDefault true;
  };
}
