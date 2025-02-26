{
  imports = [
    ./options.nix
    ./language-support.nix
    ./autocompletion.nix
    ./gui.nix
  ];

  # I'm aiming to make this config fully lua based
  # No need for other providers
  withRuby = false;
  withPython3 = false;

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
