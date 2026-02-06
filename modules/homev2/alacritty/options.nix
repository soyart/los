{ lib, ... }:

{
  options.alacritty = {
    enable = lib.mkEnableOption "Enable Alacritty terminal";
  };
}

