{ symlinkJoin, conventional-pre-commit, writeShellScriptBin }:
let
  wrapped = writeShellScriptBin "conventional-pre-commit" ''
    set -o pipefail
    ${conventional-pre-commit}/bin/conventional-pre-commit "$@" | sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g"
  '';
in symlinkJoin {
  name = "conventional-pre-commit-colorless";
  paths = [ wrapped conventional-pre-commit ];
}
