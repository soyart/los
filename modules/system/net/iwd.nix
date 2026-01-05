{ config, lib, ... }:

let
  cfg = config.los.net.iwd;

in
{
  options.los.net.iwd = {
    enable = lib.mkEnableOption "Enable iwd wireless daemon";
  };

  config = lib.mkIf cfg.enable {
    networking.wireless.iwd = {
      enable = true;
      settings = {
        Settings = {
          AutoConnect = true;
        };
      };
    };
  };
}
