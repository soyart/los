{ lib, config, pkgs, ... }:

{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    lib.mkIf userCfg.fonts.enable {
      home.packages = userCfg.fonts.packages;
      fonts = {
        fontconfig = lib.mkIf (userCfg.fonts.defaults != null) {
          enable = true;
          defaultFonts = userCfg.fonts.defaults;
        };
      };
    }
  ) config.los.homev2;
}