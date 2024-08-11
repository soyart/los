{ lib, config, ... }:

let
  types = lib.types;
  cfg = config.los.mainUser;

in
{
  options.los.mainUser = {
    enable = lib.mkEnableOption "Enable mainUser module";

    username = lib.mkOption {
      description = "Username";
      type = types.str // {
        check = (s: s != "root");
      };
      default = "los";
      example = "bob";
    };

    groups = lib.mkOption {
      description = "Extra groups other than 'weel' and `users`";
      type = types.listOf types.str // {
        check = (li: !(builtins.elem "wheel" li));
      };
      default = [ ];
      example = [ "video" "docker" ];
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups."${cfg.username}" = {
      members = [ cfg.username ];
    };

    users.users.${cfg.username} = {
      isNormalUser = true;
      home = "/home/${cfg.username}";
      createHome = true;
      extraGroups = cfg.groups ++ [ "wheel" ];
    };
  };
}
