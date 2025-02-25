{ flake, ... }:
{
  imports = [
    ./options.nix
    ./language-support.nix
    ./autocompletion.nix
    ./gui.nix
  ];
  _module.args.flake = flake;

  # Enable performance optimizations
  luaLoader.enable = true;
  performance = {
    byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      configs = true;
      plugins = true;
    };
    combinePlugins = {
      enable = true;
      standalonePlugins = [
        "nvim-treesitter"
        "everforest"
        "overseer.nvim"
        "conform.nvim"
      ];
    };
  };
}
