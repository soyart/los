{ lib, ... }:

{
  options.doas = {
    enable = lib.mkEnableOption "Enable doas for this user";
    keepEnv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Pass environment variables to the child process";
    };
    persist = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Don't ask for password again for some time after successful authentication";
    };
  };

  options.sudo = {
    enable = lib.mkEnableOption "Enable sudo for this user";
  };
}
