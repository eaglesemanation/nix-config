{
  lib,
  config,
  ...
}:
lib.mkIf (builtins.elem "godot" config.emnt.lang_support.langs) { }
