{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.bundles.dev_env.k8s;
in {
  options.bundles.dev_env.k8s.enable = mkEnableOption "Kubernetes environment";

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        kubectl kubectx kind clusterctl talosctl fluxcd cmctl kubernetes-helm
        k9s velero kubelogin-oidc;
    };
  };
}
