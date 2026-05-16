{ lib, config, pkgs, ... }:

let
  liblos = import ../../liblos { inherit lib pkgs; };
  cfg = config.los.zfs;

in
{
  options.los.zfs = {
    enable = lib.mkEnableOption "Enable iwd wireless daemon";
    enableTrim = lib.mkEnableOption "Enable iwd wireless daemon";
    hostId = lib.mkOption {
      type = liblos.extend {
        base = lib.types.str;
        check = (s: s != "");
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # The 3 options are required, per OpenZFS wiki: https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = true;
    networking.hostId = cfg.hostId;

    services.zfs.trim.enable = cfg.enableTrim;
  };
}
