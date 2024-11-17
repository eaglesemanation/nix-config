{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  bundles = {
    dev_envs.enable = true;
    secrets = {
      enable = true;
      name = "Vladimir Romashchenko";
      email = "eaglesemanation@gmail.com";
      publicKey = builtins.fetchurl {
        name = "eaglesemanation.gpg";
        url = "https://keys.openpgp.org/vks/v1/by-email/eaglesemanation%40gmail.com";
        sha256 = "sha256:1xjhfys03j02ggqygpjwnsdclvi5kn624rdn4il23a1q2v2gq1b2";
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
