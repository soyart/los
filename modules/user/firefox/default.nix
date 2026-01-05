username:

{ lib, config, pkgs, ... }:

let
  types = lib.types;

  cfg = config.los.home."${username}".firefox;

  # Read pipewire status from NixOS config directly
  pipewireEnabled = config.services.pipewire.enable;

  # Resolve pipewire: use override if set, otherwise follow system's pipewire setting
  usePipewire =
    if cfg.pipewireOverride != null
    then cfg.pipewireOverride
    else pipewireEnabled;

in
{
  options = {
    los.home."${username}".firefox = {
      enable = lib.mkEnableOption "Enable Firefox (Wayland-only)";
      pipewireOverride = lib.mkOption {
        description = "Override Pipewire support in Firefox. null = auto-detect from system config";
        type = types.nullOr types.bool;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.sessionVariables = {
        BROWSER = "firefox";
        MOZ_ENABLE_WAYLAND = "1";
      };

      programs.firefox = {
        enable = true;
        package =
          if usePipewire
          then
            pkgs.wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { }
          else
            pkgs.firefox;
      };

      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-wlr
        ];
        # Any back-end found first in lexical order
        config.common.default = "*";
      };
    };

    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };
}

