{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.home = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.eaglesemanation = {
        imports = [self.homeModules.home];
        home.stateVersion = "25.11";
      };
    };
  };

  flake.homeModules.home = {pkgs, ...}: {
    imports = [
      self.homeModules.zen-browser
    ];
    home.pointerCursor = {
      enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };
}
