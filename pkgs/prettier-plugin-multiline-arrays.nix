{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  meta = with lib; {
    description =
      "Prettier plugin to force array elements to wrap onto new lines.";
    homepage = "https://www.npmjs.com/package/prettier-plugin-multiline-arrays";
    license = getLicenseFromSpdxId "MIT";
  };

  pname = "prettier-plugin-multiline-arrays";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "electrovir";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-M9VQpXN+ALvRqmpSyq04vzf/dMXCe2aT1gX494sHNjU=";
  };

  npmBuildScript = "compile";

  npmDepsHash = "sha256-fTJlLTDHXRZemd5jwp2pR88xSqdL2dLbmNPoPOsUUq8=";
}
