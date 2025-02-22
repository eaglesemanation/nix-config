{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.emnt.dev_env.java;
in
{
  options.emnt.dev_env.java.enable = mkEnableOption "Java development environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        openjdk17
        gradle
        maven
        jdt-language-server
        ;
      inherit (pkgs.vscode-extensions.vscjava)
        vscode-java-debug
        vscode-java-test
        ;
    };

    # Include commonly used LTS JDKs
    home.sessionVariables = {
      JAVA_11_HOME = "${pkgs.openjdk11}/lib/openjdk";
      JAVA_17_HOME = "${pkgs.openjdk17}/lib/openjdk";
    };
  };
}
