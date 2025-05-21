{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "typescript" config.emnt.lang_support.langs) { }
