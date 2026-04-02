{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.desktop = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.sddm
      self.nixosModules.niri
      self.nixosModules.pipewire
    ];
    environment.systemPackages = with pkgs; [ghostty];

    security.polkit.enable = true;

    services = {
      # Power
      upower.enable = true;
      power-profiles-daemon.enable = true;
      thermald.enable = true;

      # IO
      udisks2.enable = true;
      printing.enable = true;
      geoclue2.enable = true;

      # Updates
      fwupd.enable = true;
      flatpak.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
  };
}
