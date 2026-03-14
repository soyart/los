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
            };

            xdg.portal = {
              enable = true;
              extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
              config.common.default = "*";
            };

            # You might need to uncomment this if your profile's updated.
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
                search = {
                  force = true;
                  default = "google";
                  order = [
                    "google"
                    "ddg"
                    "wikipedia"
                  ];
                  privateDefault = "ddg";
                  engines =
                    let
                      nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    in
                    {
                      "Nix Packages" = {
                        definedAliases = [ "@nixpkgs" "@np" ];
                        icon = nixIcon;
                        urls = [
                          {
                            template = "https://search.nixos.org/packages";
                            params = [
                              { name = "channel"; value = "unstable"; }
                              { name = "query"; value = "{searchTerms}"; }
                            ];
                          }
                        ];
                      };
                      "Nix Options" = {
                        definedAliases = [ "@nix" "@no" ];
                        icon = nixIcon;
                        urls = [
                          {
                            template = "https://search.nixos.org/options";
                            params = [
                              { name = "channel"; value = "unstable"; }
                              { name = "query"; value = "{searchTerms}"; }
                            ];
                          }
                        ];
                      };
                      "NixOS Wiki" = {
                        definedAliases = [ "@nixwiki" "@nixoswiki" ];
                        icon = nixIcon;
                        urls = [
                          {
                            template = "https://wiki.nixos.org/w/index.php";
                            params = [
                              { name = "search"; value = "{searchTerms}"; }
                            ];
                          }
                        ];
                      };
                      "Home-Manager Options" = {
                        definedAliases = [ "@nixhm" "@home-manager" "@hm" ];
                        icon = nixIcon;
                        urls = [
                          {
                            template = "https://home-manager-options.extranix.com/";
                            params = [
                              { name = "channel"; value = "unstable"; }
                              { name = "query"; value = "{searchTerms}"; }
                            ];
                          }
                        ];
                      };
                    };
                };
              };
            };
          }
        )
      );
    }
  ];
}

