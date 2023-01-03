{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.java;

  jdtls = pkgs.jdt-language-server.overrideAttrs (oldAttrs: rec {
    version = "1.18.0";
    timestamp = "202212011657";

    src = builtins.fetchurl {
      url =
        "https://download.eclipse.org/jdtls/milestones/${version}/jdt-language-server-${version}-${timestamp}.tar.gz";
      sha256 = "015sis2lc8k1jg3w7fy2nfrps7zw35fsarkz1w7bhp1d8h95r1xr";
    };
  });
in {
  options.bundles.dev_env.java.enable =
    mkEnableOption "Java development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) openjdk gradle;
      inherit jdtls;
    };
  };
}
