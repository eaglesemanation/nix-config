{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    attrNames
    filterAttrs
    removeSuffix
    hasSuffix
    ;

  langFilenames = attrNames (
    filterAttrs (n: v: v == "regular" && (hasSuffix ".nix" n)) (builtins.readDir ./languages)
  );
  definedLangs = builtins.map (removeSuffix ".nix") langFilenames;

  cfg = config.emnt.lang_support;
in
{
  options.emnt.lang_support = {
    enable = mkOption {
      type = types.listOf (types.enum definedLangs);
      description = "List of languages to enable support for";
      default = definedLangs;
    };
    disable = mkOption {
      type = types.listOf (types.enum definedLangs);
      description = "List of languages to exclude from support";
      default = [ ];
    };
    langs = mkOption {
      type = types.listOf (types.enum definedLangs);
      readOnly = true;
    };
    definedLangs = mkOption {
      type = types.listOf (types.enum definedLangs);
      description = "List of all languages supported, needed for useful warning messages in nixvim modules";
      default = definedLangs;
      readOnly = true;
    };
  };

  imports = builtins.map (n: ./languages + "/${n}.nix") definedLangs;
  config.emnt.lang_support.langs = lib.subtractLists cfg.disable cfg.enable;
}
