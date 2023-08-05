{ pkgs }:
let
  inherit (pkgs.lib) callPackageWith;
  callPackage = callPackageWith (pkgs // pkgs.python3Packages);
in {
  conventional-pre-commit = callPackage ./conventional-pre-commit.nix { };
  # Wrapper that strips ANSI color codes
  conventional-pre-commit-colorless =
    callPackage ./conventional-pre-commit-colorless.nix { };
  prettier-plugin-multiline-arrays =
    callPackage ./prettier-plugin-multiline-arrays.nix { };
}
