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
      self.nixosModules.sops
      self.nixosModules.nix
    ];

    networking.networkmanager.enable = true;
    hardware = {
      enableAllFirmware = true;
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
    };

    i18n.extraLocales = ["ru_RU.UTF-8/UTF-8"];

    users.users.eaglesemanation = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
    };
    nix.settings.trusted-users = ["eaglesemanation"];
    programs.nh.flake = "/home/eaglesemanation/git/nix-config";
  };
}
