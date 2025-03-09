{
  lib,
  config,
  helpers,
  ...
}:
lib.mkIf (builtins.elem "yaml" config.emnt.lang_support.langs) {
  plugins = {
    schemastore.enable = true;
    lsp.servers.yamlls = {
      enable = true;
      # By default schemastore fully overrides yamlls schemas, instead append it manually
      settings.schemas = lib.mkForce (
        helpers.mkRaw # Lua
          ''
            vim.list_extend({
              kubernetes = { "*.k8s.yaml" },
            }, require('schemastore').yaml.schemas(${helpers.toLuaObject config.plugins.schemastore.yaml.settings}))
          ''
      );
    };
  };

  extraFiles."ftdetect/kubernetes.lua".source = ./ftdetect/kubernetes.lua;
}
