# lf submodule options for los.homev2.<user>

{ lib, ... }:

{
  options.lf = {
    enable = lib.mkEnableOption "Enable lf file manager";
  };
}

