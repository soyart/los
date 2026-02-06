{ lib, ... }:

{
  options.sway = {
    enable = lib.mkEnableOption "Enable los Sway DM";
  };
}

