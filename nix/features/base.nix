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
      self.nixosModules.nix
    ];

    nix.settings.trusted-users = ["eaglesemanation"];
    users.users.eaglesemanation = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
    };
  };
}
