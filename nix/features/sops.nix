{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.sops = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    environment.systemPackages = with pkgs; [age age-plugin-yubikey sops];
  };
}
