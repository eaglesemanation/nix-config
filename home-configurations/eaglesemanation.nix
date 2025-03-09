{ lib, config, ... }:
{
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = lib.mkDefault "22.05";

  emnt = {
    secrets = {
      enable = true;
      name = "Vladimir Romashchenko";
      email = "eaglesemanation@gmail.com";
      publicKey = builtins.fetchurl {
        name = "eaglesemanation.gpg";
        url = "https://keys.openpgp.org/vks/v1/by-fingerprint/BC8AD220FEE2118ACD6FBD24C5B9ADB07DBE5A2E";
        sha256 = "sha256:1kpr9afcazsf5gmzdsg892j7m6gnh9cwlsm1aaxgfshg8s72qbjm";
      };
    };
  };

  home = {
    username = lib.mkDefault "eaglesemanation";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
  };
}
