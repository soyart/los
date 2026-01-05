{ ... }:

{
  imports = [
    ../../modules/system/net/firewall.nix
  ];

  los.net.firewall = {
    enable = true;
    global = {
      allowPing = false;
    };
  };
}
