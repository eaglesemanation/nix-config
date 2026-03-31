{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.emnt-x280-hardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x280
      self.diskoConfigurations.emnt-x280
    ];
  };
}
