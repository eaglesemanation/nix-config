{ lib, ... }:
{
  modeKeys =
    mode:
    lib.attrsets.mapAttrsToList (
      key: action:
      {
        inherit key mode;
      }
      // (if lib.isString action || lib.types.isRawType action then { inherit action; } else action)
    );

  mkIfLang =
    cfg: lang:
    let
      langIncluded = builtins.elem lang (lib.subtractLists cfg.blacklist cfg.langs);
    in
    lib.mkIf langIncluded;
}
