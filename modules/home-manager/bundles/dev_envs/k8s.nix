{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.k8s;
in {
  options.bundles.dev_env.k8s.enable = mkEnableOption "Kubernetes environment";

  config = mkIf cfg.enable {
    home.sessionPath = [ "\${KREW_HOME:-$HOME/.krew}/bin" ];

    home.packages = builtins.attrValues {
      inherit (pkgs)
        kubectl kubectx kind clusterctl talosctl fluxcd cmctl kubernetes-helm
        velero kubelogin-oidc trivy dive krew;
    };
  };
}
