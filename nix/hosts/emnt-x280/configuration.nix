{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.emnt-x280-configuration = {
    pkgs,
    lib,
    ...
  }: {
    import = [
      self.nixosModules.emnt-x280-hardware
      self.nixosModules.base
      self.nixosModules.desktop
    ];
    sops.defaultSopsFile = ./secrets.sops.yaml;
  };
}
