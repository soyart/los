{ ... }:

{
  imports = [
    ../../nixos/net
    ./default.nix
  ];

  los.net = {
    iwd.enable = true;
  };
}
