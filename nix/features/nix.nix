{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nix = {
    pkgs,
    lib,
    ...
  }: {
    nix.settings.experimental-features = ["nix-command" "flakes"];
  };
}
