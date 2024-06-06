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

    programs.k9s = {
      enable = true;
      settings = {
        k9s.ui = {
          enableMouse = true;
          reactive = true;
          skin = "solarized_dark";
        };
      };
      skins = {
        solarized_dark = let
          foreground = "#839495";
          background = "#002833";
          current_line = "#003440";
          selection = "#003440";
          comment = "#6272a4";
          cyan = "#2aa197";
          green = "#859901";
          orange = "#cb4a16";
          magenta = "#d33582";
          blue = "#2aa198";
          red = "#dc312e";
        in {
          k9s = {
            body = {
              fgColor = foreground;
              bgColor = background;
              logoColor = blue;
            };
            prompt = {
              fgColor = foreground;
              bgColor = background;
              suggestColor = orange;
            };
            info = {
              fgColor = magenta;
              sectionColor = foreground;
            };
            dialog = {
              fgColor = foreground;
              bgColor = background;
              buttonFgColor = foreground;
              buttonBgColor = magenta;
              buttonFocusFgColor = "white";
              buttonFocusBgColor = cyan;
              labelFgColor = orange;
              fieldFgColor = foreground;
            };
            frame = {
              border = {
                fgColor = selection;
                focusColor = current_line;
              };
              menu = {
                fgColor = foreground;
                keyColor = magenta;
                numKeyColor = magenta;
              };
              crumbs = {
                fgColor = foreground;
                bgColor = current_line;
                activeColor = current_line;
              };
              status = {
                newColor = cyan;
                modifyColor = blue;
                addColor = green;
                errorColor = red;
                highlightColor = orange;
                killColor = comment;
                completedColor = comment;
              };
              title = {
                fgColor = foreground;
                bgColor = current_line;
                highlightColor = orange;
                counterColor = blue;
                filterColor = magenta;
              };
              views = {
                charts = {
                  bgColor = "default";
                  defaultDialColor = [ blue red ];
                  defaultChartColors = [ blue red ];
                };
                table = {
                  fgColor = foreground;
                  bgColor = background;
                  cursorFgColor = selection;
                  cursorBgColor = current_line;
                  header = {
                    fgColor = foreground;
                    bgColor = background;
                    sorterColor = cyan;
                  };
                };
                xray = {
                  fgColor = foreground;
                  bgColor = background;
                  cursorColor = current_line;
                  graphicColor = blue;
                  showIcons = "false";
                };
                yaml = {
                  keyColor = magenta;
                  colonColor = blue;
                  valueColor = foreground;
                };
                logs = {
                  fgColor = foreground;
                  bgColor = background;
                  indicator = {
                    fgColor = foreground;
                    bgColor = selection;
                    toggleOnColor = magenta;
                    toggleOffColor = blue;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
