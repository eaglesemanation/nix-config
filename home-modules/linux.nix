# Automatically imported by ez-configs if targets linux device
{ inputs, ... }:
{
  targets.genericLinux.enable = true;
  # Enables nix in zsh environment
  programs.zsh.initExtraFirst = ''
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    . ~/.nix-profile/etc/profile.d/hm-session-vars.sh 
  '';
  nixGL.packages = inputs.nixgl.packages;

  systemd.user.startServices = "sd-switch";
  xdg.enable = true;
  fonts.fontconfig.enable = true;
}
