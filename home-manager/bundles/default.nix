{ pkgs, ... }:
{
  imports = [
    ./cli_tools.nix
    ./dev_envs
    ./nvim.nix
    ./secrets.nix
    ./terminal.nix
  ];
  
  bundles = {
    terminal.enable = true;
    nvim.enable = true;
  };
}
