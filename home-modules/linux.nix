# Automatically imported by ez-configs if targets linux device
{ inputs, lib, ... }:
{
  targets.genericLinux.enable = true;
  nixGL.packages = inputs.nixgl.packages;

  systemd.user.startServices = "sd-switch";
  xdg.enable = true;
  fonts.fontconfig.enable = true;
}
