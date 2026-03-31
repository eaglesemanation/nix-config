{
  self,
  inputs,
  ...
}: {
  flake.nixosConfiguration.emnt-x280 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.emnt-x280-configuration
    ];
  };
}
