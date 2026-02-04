{ lib, config, pkgs, ... }:

let
  # Read pipewire status from NixOS config directly
  pipewireEnabled = config.services.pipewire.enable;

in
{
  config = lib.mkMerge [
    # Per-user home-manager config
    {
      home-manager.users = lib.mapAttrs
        (username: userCfg:
          let
            usePipewire =
              if userCfg.firefox.pipewireOverride != null
              then userCfg.firefox.pipewireOverride
              else pipewireEnabled;
          in
          lib.mkIf userCfg.firefox.enable {
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
        )
        config.los.homev2;
    }

    # System-level config (if ANY user has firefox enabled)
    (lib.mkIf (lib.any (u: u.firefox.enable) (lib.attrValues config.los.homev2)) {
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    })
  ];
}

