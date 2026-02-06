{ lib, config, pkgs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
  # Read pipewire status from NixOS config directly
  pipewireEnabled = config.services.pipewire.enable;
in
{
  config = lib.mkMerge [
    # Per-user home-manager config
    {
      home-manager.users = homev2.forEachEnabled config "firefox" (username: firefoxCfg:
        let
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

          programs.firefox = {
            enable = true;
            package =
              if usePipewire
              then pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { }
              else pkgs.firefox;
          };

          xdg.portal = {
            enable = true;
            extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
            config.common.default = "*";
          };
        }
      );
    }

    # System-level config (if ANY user has firefox enabled)
    (lib.mkIf (homev2.anyEnabled config "firefox") {
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    })
  ];
}

