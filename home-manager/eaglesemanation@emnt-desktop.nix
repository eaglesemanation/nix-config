{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  bundles = {
    dev_envs = {
      enable = true;
    };
    secrets = {
      enable = true;
      name = "Vladimir Romashchenko";
      email = "eaglesemanation@gmail.com";
      publicKey = builtins.fetchurl {
        name = "eaglesemanation.gpg";
        url = "https://keys.openpgp.org/vks/v1/by-email/eaglesemanation%40gmail.com";
        sha256 = "sha256:1kpr9afcazsf5gmzdsg892j7m6gnh9cwlsm1aaxgfshg8s72qbjm";
      };
    };
  };

  home = {
    username = lib.mkDefault "eaglesemanation";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
  };

  host_os.fedora = {
    enable = true;
    opengl.kind = "mesa";
  };
}
