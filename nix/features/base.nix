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
    imports = [
      self.nixosModules.secureBoot
      self.nixosModules.network
      self.nixosModules.sops
    ];

    users.users.eaglesemanation = {
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}
