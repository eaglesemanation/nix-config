{
  lib,
  config,
  helpers,
  ...
}:
lib.mkIf (builtins.elem "yaml" config.emnt.lang_support.langs) {
  plugins = {
    schemastore = {
      enable = true;
      yaml.enable = true;
    };
    lsp.servers.yamlls.enable = true;
  };

  extraFiles."ftdetect/kubernetes.lua".source = ./ftdetect/kubernetes.lua;
}
