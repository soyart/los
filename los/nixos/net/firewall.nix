{ lib, config, ... }:

let
  types = lib.types;
  cfg = config.los.net.firewall;

  fw = {
    options = {
      allowPing = lib.mkOption {
        description = "Allow ping when firewall is up";
        type = types.bool;
        default = false;
      };

      portsTcp = lib.mkOption {
        description = "Open TCP ports";
        type = types.listOf types.int;
        default = [ ];
      };

      portsUdp = lib.mkOption {
        description = "Open UDP ports";
        type = types.listOf types.int;
        default = [ ];
      };
    };
  };

in
{
  options.los.net.firewall = {
    enable = lib.mkEnableOption "Enable los firewall";
    global = lib.mkOption {
      description = "Global firewall for all network interfaces";
      type = types.submodule fw;
      default = { };
    };

    # interfaces = lib.mkOption{
    #   description = "Maps names of interfaces to los firewall";
    #   type = attrsOf (submodule fw);
    #   default = {};
    # };
  };

  config = lib.mkIf cfg.enable {
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true;
      allowPing = cfg.global.allowPing;
      allowedUDPPorts = cfg.global.portsUdp;
      allowedTCPPorts = cfg.global.portsTcp;
    };
  };
}
