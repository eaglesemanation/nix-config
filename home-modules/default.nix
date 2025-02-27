{ inputs, lib, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./cli_tools.nix
    ./dev_envs
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
