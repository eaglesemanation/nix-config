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
      bootspec.enable = true;
      plymouth.enable = true;
      initrd.systemd.enable = true;
      loader.systemd-boot.enable = lib.mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
