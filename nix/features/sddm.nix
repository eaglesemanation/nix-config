{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.sddm = {
    pkgs,
    lib,
    ...
  }: let
    selfPackages = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    environment.systemPackages = with pkgs; [
      selfPackages.sddm-noctalia-theme
    ];
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "sddm-noctalia-theme";
      enableHidpi = true;
      extraPackages = with pkgs.kdePackages; [qt5compat];
    };
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.sddm-noctalia-theme =
      pkgs.stdenvNoCC.mkDerivation
      (finalAttrs: {
        name = "sddm-noctalia-theme";
        meta = {
          description = "Custom SDDM login themes inspired by Noctalia";
          homepage = "https://github.com/mahaveergurjar/sddm/tree/noctalia";
        };

        src = pkgs.fetchFromGitHub {
          owner = "mahaveergurjar";
          repo = "sddm";
          rev = "noctalia";
          hash = "sha256-q/aw4PLSHhS2jKjRl8F1JIBZn1aBV/QBEDgZ+2Oyo2A=";
        };

        dontBuild = true;
        dontWrapQtApps = true;

        propagatedBuildInputs = with pkgs.kdePackages; [
          qt5compat
        ];

        installPhase = let
          basePath = "$out/share/sddm/themes/sddm-noctalia-theme";
          iniFormat = pkgs.formats.ini {};
          configFile = iniFormat.generate "" {
            General = {
              background = "Assets/background.png";
              # Blur radius for the background
              blurRadius = 0;
              # Color Scheme (Everforest)
              mPrimary = "#A7C080";
              mOnPrimary = "#232A2E";
              mSecondary = "#D3C6AA";
              mOnSecondary = "#232A2E";
              mTertiary = "#9DA9A0";
              mOnTertiary = "#232A2E";
              mError = "#E67E80";
              mOnError = "#232A2E";
              mSurface = "#232A2E";
              mOnSurface = "#859289";
              mSurfaceVariant = "#2D353B";
              mOnSurfaceVariant = "#D3C6AA";
              mOutline = "#7A8478";
              mShadow = "#475258";
              mHover = "#A7C080";
              mOnHover = "#232A2E";
            };
          };
        in ''
          mkdir -p ${basePath}
          cp -r $src/* ${basePath}
          ln -sf ${configFile} ${basePath}/theme.conf
        '';
      });
  };
}
