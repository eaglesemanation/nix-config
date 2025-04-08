{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "rust" config.emnt.lang_support.langs) {
  plugins = {
    rustaceanvim = {
      enable = true;
      settings.tools.test_executor = "neotest";
    };
  };
}
