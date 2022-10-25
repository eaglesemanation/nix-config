{ lib, ... }:
let
  inherit (lib) attrNames filterAttrs flatten hasPrefix;
  # Tries reading from a path, if doesn't exist - return empty attrset
  read_dir = path:
    if builtins.pathExists path then builtins.readDir path else { };
  # Lists all files and symlinks that don't start with .
  list_files = path:
    attrNames (filterAttrs (name: type:
      !(hasPrefix "." name) && (builtins.elem type [ "regular" "symlink" ]))
      (read_dir path));
  # Converts derivations to a list of paths with binaries
  bin_paths = drvs: builtins.map (drv: "${drv}/bin/") drvs;
  # Lists all binaries in a given list of derivations
  derivations_bins = drvs: flatten (builtins.map list_files (bin_paths drvs));
in { inherit derivations_bins; }
