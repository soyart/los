# Sway submodule options for los.homev2.<user>

{ lib, ... }:

{
  options.sway = {
    enable = lib.mkEnableOption "Enable los Sway DM";
  };
}

