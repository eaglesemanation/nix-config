{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "terraform" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers.terraformls.enable = true;
  };
}
