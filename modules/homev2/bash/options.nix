{ lib, ... }:

{
  options.bash = {
    enable = lib.mkEnableOption "Enable Bash shell with los defaults";
  };
}

