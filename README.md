# Nix-config

Dendritic NixOS setup

## Installing to a fresh host
1. Load into NixOS live ISO, exit from GUI install
2. Generate Secure Boot keys: `sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#sbctl create-keys`
3. Partition disks: `sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake github:eaglesemanation/nix-config#<hostname>`
4. Copy Secure Boot keys to mounted volumes: `sudo mkdir -p /mnt/var/lib/ && sudo cp -r /var/lib/sbctl /mnt/var/lib/sbctl`
5. Install: `sudo env NIXPKGS_ALLOW_UNFREE=1 nixos-install --impure --flake github:eaglesemanation/nix-config#<hostname>`
