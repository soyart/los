# Fonts config module

{ lib, config, ... }:

{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    lib.mkIf userCfg.fonts.enable {
      home.packages = lib.mkIf (userCfg.fonts.packages != []) userCfg.fonts.packages;
      fonts = {
        fontconfig = lib.mkIf (userCfg.fonts.defaults != null) {
          enable = true;
          defaultFonts = userCfg.fonts.defaults;
        };
      };
    }
  ) config.los.homev2;
}

