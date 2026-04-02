{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.secureBoot = {
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.lanzaboote.nixosModules.default];

    boot = {
      plymouth = let
        theme = "hexagon";
      in {
        enable = true;
        inherit theme;
        themePackages = [
          (pkgs.adi1090x-plymouth-themes.override {
            selected_themes = [theme];
          })
        ];
      };
      kernelParams = ["quiet" "splash"];

      bootspec.enable = true;
      initrd.systemd.enable = true;
      loader = {
        timeout = 0;
        systemd-boot.enable = lib.mkForce false;
      };
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
