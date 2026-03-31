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
    # Modules that act as desktop environment
    imports = [
      self.flake.nixosModules.niri
    ];
  };
}
