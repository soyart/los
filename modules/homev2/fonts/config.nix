{ lib, config, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
in
{
  config.home-manager.users = homev2.forEachEnabled config "fonts" (username: fontsCfg: {
    home.packages = fontsCfg.packages;
    fonts = {
      fontconfig = lib.mkIf (fontsCfg.defaults != null) {
        enable = true;
        defaultFonts = fontsCfg.defaults;
      };
    };
  });
}
