{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {
    pkgs,
    lib,
    ...
  }: let
    selfPackages = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    programs.niri = {
      enable = true;
      package = selfPackages.niri;
    };
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    noctaliaExe = lib.getExe self'.packages.noctalia-shell;
    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  in {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [noctaliaExe];
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        input = {
          keyboard.xkb = {
            layout = "us,ru";
            options = "grp:alt_shift_toggle";
          };
          touchpad = {
            tap = _: {};
            natural-scroll = _: {};
          };
        };
        layout.gaps = 10;
        window-rules = [
          {
            geometry-corner-radius = 20;
            clip-to-geometry = true;
          }
        ];
        debug = {
          honor-xdg-activation-with-invalid-serial = _: {};
        };
        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
          "Mod+Q".close-window = _: {};
          "Mod+Space".spawn-sh = "${noctaliaExe} ipc call launcher toggle";

          XF86MonBrightnessUp.spawn-sh = "${noctaliaExe} ipc call brightness increase";
          XF86MonBrightnessDown.spawn-sh = "${noctaliaExe} ipc call brightness decrease";

          XF86AudioRaiseVolume.spawn-sh = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          XF86AudioLowerVolume.spawn-sh = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          XF86AudioMute = _: {
            props = {allow-when-locked = true;};
            content = {
              spawn-sh = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
            };
          };
        };
      };
    };
  };
}
