username:

{ lib, config, pkgs, ... }:

let
  types = lib.types;
  cfg = config.los.home."${username}".gui.fonts;

in
{
  options = {
    los.home."${username}".gui.fonts = {
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

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = cfg.packages;
      fonts = {
        fontconfig = lib.mkIf (cfg.defaults != null) {
          enable = true;
          defaultFonts = cfg.defaults;
        };
      };
    };
  };
}
