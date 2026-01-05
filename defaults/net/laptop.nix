{ ... }:

{
  imports = [
    ../../nixos/net
    ./.
  ];

  los.net = {
    iwd.enable = true;
  };
}
