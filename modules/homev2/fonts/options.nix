# Fonts submodule options for los.homev2.<user>

{ lib, ... }:

let
  types = lib.types;

in
{
  options.fonts = {
    enable = lib.mkEnableOption "Install fonts for GUI";

    packages = lib.mkOption {
      description = "Font packages to install";
      type = types.listOf types.package;
      default = [];
    };

    defaults = lib.mkOption {
      description = "Default font names for each typeface family";
      type = types.nullOr (types.attrsOf (types.listOf types.str));
      default = null;
      example = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Liberation" "Noto" ];
        monospace = [ "Hack" ];
      };
    };
  };
}

