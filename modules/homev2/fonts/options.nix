{ lib, pkgs, ... }:

let
  types = lib.types;

in
{
  options.fonts = {
    enable = lib.mkEnableOption "Install fonts for GUI";

    packages = lib.mkOption {
      description = "Normal TTF fonts";
      type = types.listOf types.package;
      default = with pkgs; [
        hack-font
        inconsolata
        liberation_ttf
        tlwg
        nerd-fonts.hack
      ];
      example = with pkgs; [
        inconsolata
        liberation_ttf
      ];
    };

    defaults = lib.mkOption {
      description = "Default font names for each typeface family";
      type = types.nullOr (types.attrsOf (types.listOf types.str));
      default = { };
      example = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Liberation" "Noto" ];
        monospace = [ "Hack" ];
      };
    };
  };
}

