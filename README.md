# Nix-config

Dendritic NixOS setup

## Installing on a fresh host
1. Disable Secure Boot in UEFI and switch to Setup Mode
2. Load into NixOS live ISO, exit from GUI install
3. Generate Secure Boot keys: `sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#sbctl create-keys`
4. Partition disks: `sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:eaglesemanation/nix-config#<hostname>`
5. Copy Secure Boot keys to mounted volumes: `sudo mkdir -p /mnt/var/lib/ && sudo cp -r /var/lib/sbctl /mnt/var/lib/sbctl`
6. Install: `sudo env NIXPKGS_ALLOW_UNFREE=1 nixos-install --impure --flake github:eaglesemanation/nix-config#<hostname>`
7. Reboot into installed OS, enter encryption password
8. Enroll keys: `sudo nix run nixpkgs#sbctl enroll-keys -- --microsoft`
9. Reboot into UEFI, enable Secure Boot. Reboot into OS again
10. Enroll TPM for unlocking encrypted drive: `sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 <block_device_path>`
