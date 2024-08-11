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

      ttf = lib.mkOption {
        description = "Normal TTF fonts";
        type = types.listOf types.package;
        default = with pkgs; [
          inconsolata
          liberation_ttf
        ];
        example = with pkgs; [
          inconsolata
          liberation_ttf
        ];
      };

      nerd = lib.mkOption {
        description = "Nerd Fonts for override";
        type = types.listOf types.str;
        default = [ ];
        example = [
          "Hack"
          "Inconsolata"
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
      home.packages =
        if (builtins.length cfg.nerd != 0)
        then cfg.ttf ++ [
          (pkgs.nerdfonts.override { fonts = cfg.nerd; })
        ]

        else cfg.ttf;

      fonts = {
        fontconfig = lib.mkIf (cfg.defaults != null) {
          enable = true;
          defaultFonts = cfg.defaults;
        };
      };
    };
  };
}
