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
      type = types.addCheck types.str (
        s: s != "root"
      );
      default = "los";
      example = "bob";
    };

    groups = lib.mkOption {
      description = "Extra groups other than 'weel' and `users`";
      type = types.addCheck (types.listOf types.str) (
        li: !(builtins.elem "wheel" li)
      );
      default = [ ];
      example = [ "video" "docker" ];
    };

    hashedPassword = lib.mkOption {
      type = types.str // {
        check = (s: s != "");
      };
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
      hashedPassword = cfg.hashedPassword;
    };
  };
}
