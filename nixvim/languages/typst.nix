{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "typst" config.emnt.lang_support.langs) {
  plugins = {
    lsp.servers.tinymist = {
      enable = true;
      settings = {
        formatterMode = "typstyle";
        exportPdf = "onType";
      };
    };
    typst-preview.enable = true;
  };
}
