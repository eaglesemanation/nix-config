{ pkgs }:
let
  inherit (pkgs.lib) callPackageWith;
  callPackage = callPackageWith (pkgs // pkgs.python3Packages);
in { conventional-pre-commit = callPackage ./conventional-pre-commit.nix { }; }
