{ lib, config, pkgs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
  # Read pipewire status from NixOS config directly
  pipewireEnabled = config.services.pipewire.enable;
in
{
  config = lib.mkMerge [
    (lib.mkIf (homev2.anyEnabled config "firefox") {
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    })

    {
      home-manager.users = homev2.mkConfigPerUser config (username: userCfg:
        lib.mkIf userCfg.firefox.enable (
          let
            firefoxCfg = userCfg.firefox;
            usePipewire =
              if firefoxCfg.pipewireOverride != null
              then firefoxCfg.pipewireOverride
              else pipewireEnabled;
          in
          {
            home.sessionVariables = {
              BROWSER = "firefox";
              MOZ_ENABLE_WAYLAND = "1";
            };

            # home.file.".mozilla/firefox/profiles.ini".force = true;

            programs.firefox = {
              enable = true;
              package =
                if usePipewire
                then pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { }
                else pkgs.firefox;

              policies = {
                AppAutoUpdate = false;
                BackgroundAppUpdate = false;

                DisableTelemetry = true;
                DisableFirefoxStudies = true;
                EnableTrackingProtection = {
                  Value = true;
                  Locked = true;
                  Cryptomining = true;
                  Fingerprinting = true;
                };

                DontCheckDefaultBrowser = true;
                DisablePocket = true;
                SearchBar = "unified";
              };

              profiles.default = {
                id = 0;
                isDefault = true;
                settings = {
                  # Disable AI features
                  "browser.ml.chat.enabled" = false;
                  "browser.ml.chat.page" = false;
                  "browser.ml.linkPreview.enabled" = false;
                  "browser.tabs.groups.smart.enabled" = false;
                  "browser.tabs.groups.smart.userEnabled" = false;
                  "browser.translations.enable" = false;
                  "browser.ai.control.default" = "blocked";
                  "browser.ai.control.linkPreviewKeyPoints" = "blocked";
                  "browser.ai.control.pdfjsAltText" = "blocked";
                  "browser.ai.control.sidebarChatbot" = "blocked";
                  "browser.ai.control.smartTabGroups" = "blocked";
                  "browser.ai.control.translations" = "blocked";
                  "extensions.ml.enabled" = false;
                  "pdfjs.enableAltText" = false;
                };
              };
            };

            xdg.portal = {
              enable = true;
              extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
              config.common.default = "*";
            };
          }
        )
      );
    }
  ];
}

