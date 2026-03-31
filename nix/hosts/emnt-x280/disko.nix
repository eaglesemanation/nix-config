{
  self,
  inputs,
  ...
}: let
  defaultBtrfsOpts = ["defaults" "compress=zstd:1" "ssd" "noatime" "nodiratime"];
in {
  flake.diskoConfigurations.emnt-x280 = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptroot";
                  settings.allowDiscards = true;
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes = {
                      "@" = {
                        mountpoint = "/";
                        mountOptions = defaultBtrfsOpts;
                      };
                      "/home" = {
                        mountpoint = "/home";
                        mountOptions = defaultBtrfsOpts;
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = defaultBtrfsOpts;
                      };
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile.size = "8G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
