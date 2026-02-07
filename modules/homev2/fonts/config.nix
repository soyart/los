{ lib, config, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
in
{
  config.home-manager.users = homev2.mkPerUserConfig config (username: userCfg:
    lib.mkIf userCfg.fonts.enable (
      let fontsCfg = userCfg.fonts; in
      {
        home.packages = fontsCfg.packages;
        fonts = {
          fontconfig = lib.mkIf (fontsCfg.defaults != null) {
            enable = true;
            defaultFonts = fontsCfg.defaults;
          };
        };
      }
    )
  );
}
