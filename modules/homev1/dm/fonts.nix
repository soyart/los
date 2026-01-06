username:

{ lib, config, pkgs, ... }:

let
  types = lib.types;
  cfg = config.los.homev1."${username}".dm;

in
{
  options = {
    los.homev1."${username}".dm = {
      fonts = {
        enable = lib.mkEnableOption "Install fonts for GUI";

        packages = lib.mkOption {
          description = "Normal TTF fonts";
          type = types.listOf types.package;
          default = with pkgs; [
            hack-font
            inconsolata
            liberation_ttf
          ];
          example = with pkgs; [
            inconsolata
            liberation_ttf
          ];
        };

        defaults = lib.mkOption {
          description = "Default font names for each typeface family";
          type = types.attrsOf (types.listOf types.str);
          default = null;
          example = {
            serif = [
              "Ubuntu"
            ];
            sansSerif = [
              "Liberation"
              "Noto"
            ];
            monospace = [
              "Hack"
            ];
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.fonts.enable {
    home-manager.users."${username}" = {
      home.packages = cfg.fonts.packages;
      fonts = {
        fontconfig = lib.mkIf (cfg.fonts.defaults != null) {
          enable = true;
          defaultFonts = cfg.fonts.defaults;
        };
      };
    };
  };
}

