username:

{ lib, config, pkgs, ... }:

let
  types = lib.types;

  perUser = config.los.home."${username}";
  cfg = perUser.gui.progs.firefox;
  cfgSway = perUser.gui.progs.sway;

in
{
  options = {
    los.home."${username}".gui.progs.firefox = {
      enable = lib.mkEnableOption "Enable Firefox (Wayland-only)";
      withPipewire = lib.mkOption {
        description = "Enable Pipewire support in Firefox (i.e. for screen sharing and web conferences)";
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.pipewire.enable = cfg.withPipewire;

    home-manager.users."${username}" = {
      home.sessionVariables = {
        BROWSER = "firefox";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_CURRENT_DESKTOP = lib.mkIf cfgSway.enable "sway";
      };

      programs.firefox = {
        enable = true;
        package =
          if cfg.withPipewire
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
