{ lib, buildPythonApplication, fetchPypi }:

buildPythonApplication rec {
  pname = "conventional-pre-commit";
  version = "2.1.1";

  src = fetchPypi {
    inherit version;
    pname = "conventional_pre_commit";
    sha256 = "sha256-/NISRq/o25iSqQzxRAY50rrpSLnMmdX5K1WJuEUYWGM=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/compilerla/conventional-pre-commit";
    description =
      "A pre-commit hook that checks commit messages for Conventional Commits formatting";
    license = licenses.asl20;
  };
}
