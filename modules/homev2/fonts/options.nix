# Fonts submodule options for los.homev2.<user>

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
      ];
      example = with pkgs; [
        inconsolata
        liberation_ttf
      ];
    };

    defaults = lib.mkOption {
      description = "Default font names for each typeface family";
      type = types.nullOr (types.attrsOf (types.listOf types.str));
      default = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Liberation" "Noto" ];
        monospace = [ "Hack" ];
      };
      example = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Liberation" "Noto" ];
        monospace = [ "Hack" ];
      };
    };
  };
}

