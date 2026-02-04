{ lib, pkgs, ... }:

let
  types = lib.types;

in
{
  options.git = {
    enable = lib.mkEnableOption "Enable los Git";

    withLfs = lib.mkOption {
      description = "Enable Git LFS support";
      type = types.bool;
      default = false;
    };

    username = lib.mkOption {
      description = "Git username (defaults to system username if null)";
      type = types.nullOr types.str;
      default = null;
    };

    email = lib.mkOption {
      description = "Git email";
      type = types.nullOr types.str;
      default = null;
    };

    editor = {
      package = lib.mkOption {
        description = "Nix package for git $EDITOR program";
        type = types.package;
        default = pkgs.helix;
      };

      binPath = lib.mkOption {
        description = "Path to executable from the derivation root of package";
        type = types.str;
        default = "bin/hx";
      };
    };
  };
}

