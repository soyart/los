# Fonts config module

{ lib, config, pkgs, ... }:

{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    lib.mkIf userCfg.fonts.enable {
      home.packages = userCfg.fonts.packages;
      fonts = lib.mkIf (userCfg.fonts.defaults != null) {
        fontconfig = {
          enable = true;
          defaultFonts = userCfg.fonts.defaults;
        };
      };
    }
  ) config.los.homev2;
}

