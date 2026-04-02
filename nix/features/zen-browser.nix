{
  self,
  inputs,
  ...
}: {
  flake.homeModules.zen-browser = {pkgs, ...}: {
    imports = [inputs.zen-browser.homeModules.beta];
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
      policies = let
        extension = id: attrs: {
          ${id} =
            {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
            }
            // attrs;
        };
      in {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        SkipTermsOfUse = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        UserMessaging = {
          SkipOnboarding = true;
        };
        GenerativeAI.Enabled = false;
        ExtensionSettings =
          (extension "uBlock0@raymondhill.net" {installation_mode = "normal_installed";})
          // (extension "firefox@betterttv.net" {installation_mode = "normal_installed";})
          // (extension "addon@darkreader.org" {installation_mode = "normal_installed";})
          // (extension "deArrow@ajay.app" {installation_mode = "normal_installed";})
          // (extension "sponsorBlocker@ajay.app" {installation_mode = "normal_installed";})
          // (extension "gdpr@cavi.au.dk" {installation_mode = "normal_installed";})
          # Violentmonkey
          // (extension "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" {installation_mode = "normal_installed";})
          # Bitwarden
          // (extension "{446900e4-71c2-419f-a6a7-df9c091e268b}" {installation_mode = "normal_installed";})
          # Return YouTube dislike
          // (extension "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" {installation_mode = "normal_installed";});
      };
    };
  };
}
