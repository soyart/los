# Alacritty submodule options for los.homev2.<user>

{ lib, ... }:

{
  options.alacritty = {
    enable = lib.mkEnableOption "Enable Alacritty terminal";
  };
}

