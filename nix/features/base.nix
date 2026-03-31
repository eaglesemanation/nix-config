{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.base = {
    pkgs,
    lib,
    ...
  }: {
    # Modules that should be included on every personal device
    imports = [
      self.flake.nixosModules.secureBoot
      self.flake.nixosModules.sops
    ];
  };
}
