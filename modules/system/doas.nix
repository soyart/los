{ lib, config, pkgs, ... }:

let
  liblos = import ../../liblos { inherit lib pkgs; };
  types = lib.types;
  cfg = config.los.doas;

  mapNoPassword = c: {
    inherit (c) cmd runAs keepEnv setEnv;

    users = [ c.username ];
    persist = false;
    noPass = true;
  };

in
{
  options.los.doas = {
    enable = lib.mkEnableOption "Globally enable doas";

    keepSudo = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Keep sudo on the system";
    };

    settings = {
      users = lib.mkOption {
        type = types.listOf types.str;
        description = "List of usernames with doas enabled";
      };
      groups = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of user groups with doas enabled";
      };
      keepEnv = lib.mkOption {
        type = types.bool;
        default = true;
      };
      persist = lib.mkOption {
        type = types.bool;
        default = true;
      };
    };

    noPasswords = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          username = lib.mkOption {
            type = types.str;
          };
          cmd = lib.mkOption {
            type = liblos.extend {
              base = types.path;
              check = (p: builtins.pathExists p);
            };
          };
          keepEnv = lib.mkOption {
            type = types.bool;
            default = true;
          };
          setEnv = lib.mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          runAs = lib.mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      });

      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo.enable = cfg.keepSudo;

    security.doas.enable = true;
    security.doas.extraRules = [{
      users = cfg.settings.users;
      groups = cfg.settings.groups;
      keepEnv = cfg.settings.keepEnv;
      persist = cfg.settings.persist;
    }] ++ (map mapNoPassword cfg.noPasswords);

    environment.systemPackages = with pkgs; [
      doas-sudo-shim
    ];
  };
}
