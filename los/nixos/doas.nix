{ lib, config, pkgs, ... }:

let
  types = lib.types;
  cfg = config.los.doas;

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
  };

  config = lib.mkIf cfg.enable {
    security.sudo.enable = cfg.keepSudo;

    security.doas.enable = true;
    security.doas.extraRules = [{
      users = cfg.settings.users;
      groups = cfg.settings.groups;
      keepEnv = cfg.settings.keepEnv;
      persist = cfg.settings.persist;
    }];

    environment.systemPackages = with pkgs; [
      doas-sudo-shim
    ];
  };
}
