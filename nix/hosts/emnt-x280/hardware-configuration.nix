{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.emnt-x280-hardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x280
      self.diskoConfigurations.emnt-x280
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
    boot.kernelModules = ["kvm-intel"];
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.enableAllFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;
  };
}
