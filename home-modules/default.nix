{ ... }:
{
  imports = [
    ./cli_tools.nix
    ./dev_envs
    ./nvim.nix
    ./secrets.nix
    ./terminal.nix
  ];

  emnt = {
    terminal.enable = true;
    nvim.enable = true;
    cli_tools.enable = true;
  };
}
