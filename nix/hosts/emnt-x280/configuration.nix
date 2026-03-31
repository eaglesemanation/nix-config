{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.emnt-x280 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      self.nixosModules.emnt-x280-configuration
    ];
  };

  flake.nixosModules.emnt-x280-configuration = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.emnt-x280-hardware
      self.nixosModules.base
      self.nixosModules.desktop
    ];
    networking.hostName = "emnt-x280";
    time.timeZone = "America/Toronto";
    sops.defaultSopsFile = ./secrets.sops.yaml;
    system.stateVersion = "25.11";
  };
}
