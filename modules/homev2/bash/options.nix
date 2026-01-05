# Bash submodule options for los.homev2.<user>

{ lib, ... }:

{
  options.bash = {
    enable = lib.mkEnableOption "Enable Bash with los defaults";
  };
}

