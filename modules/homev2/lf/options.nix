{ lib, ... }:

{
  options.lf = {
    enable = lib.mkEnableOption "Enable lf file manager";
  };
}

