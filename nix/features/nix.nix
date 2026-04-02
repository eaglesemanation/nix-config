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
    imports = [inputs.nix-index-database.nixosModules.nix-index];
    programs.nix-index-database.comma.enable = true;

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [nix-inspect];

    services.envfs.enable = true;
    programs.nix-ld.enable = true;
  };
}
