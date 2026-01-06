{ ... }:

{
  imports = [
    ../../../modules/system/net/unbound.nix
  ];

  los.net.unboundDoT = {
    enable = true;
    nameserversDoT = [
      "1.1.1.1@853#one.one.one.one"
      "1.0.0.1@853#one.one.one.one"
      "9.9.9.9@853#dns.quad9.net"
    ];
  };
}
