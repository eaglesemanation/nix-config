{ pkgs }:
let
  inherit (pkgs.lib) callPackageWith;
  callPackage = callPackageWith (pkgs // pkgs.python3Packages);
in {
  prettier-plugin-multiline-arrays =
    callPackage ./prettier-plugin-multiline-arrays.nix { };
}
