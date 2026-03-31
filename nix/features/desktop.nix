{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.desktop = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.niri
    ];
    environment.systemPackages = with pkgs; [ghostty];
  };
}
